package gravit.code.test.fixture.support;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.test.fixture.dto.internal.QaFixtureLoadResultDto;
import gravit.code.test.fixture.dto.internal.QaRankMemberDto;
import gravit.code.test.fixture.dto.response.QaFixtureManifestResponse;
import gravit.code.test.fixture.dto.response.QaPersonaManifestResponse;
import gravit.code.user.infrastructure.RedisUserCleanManager;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.support.EncodedResource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.ACTIVE_SEASON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.QA_FIXTURE_PREREQUISITE_MISSING;
import static gravit.code.global.exception.domain.CustomErrorCode.QA_FIXTURE_RELOAD_IN_PROGRESS;
import static gravit.code.test.fixture.sql.QaFixtureSql.DELETE_USER_DAILY_ACTIVITY_SQL;
import static gravit.code.test.fixture.sql.QaFixtureSql.FIND_PERSONA_USER_IDS_SQL;
import static gravit.code.test.fixture.sql.QaFixtureSql.FIND_RANK_MEMBERS_SQL;
import static gravit.code.test.fixture.sql.QaFixtureSql.FIND_USER_IDS_SQL;
import static gravit.code.test.fixture.sql.QaFixtureSql.PREREQUISITE_SQL;
import static gravit.code.test.fixture.sql.QaFixtureSql.SET_LOCAL_TIME_ZONE_SQL;

@Profile("!prod")
@Component
@RequiredArgsConstructor
public class QaFixtureReloader {

    private static final String SCRIPT_DIRECTORY = "sql/seed/qa/";
    private static final List<String> SCRIPT_FILES = List.of(
            "01_users.sql",
            "02_onboarding.sql",
            "03_learning.sql",
            "04_social.sql",
            "05_league.sql",
            "06_interview.sql",
            "07_inquiry.sql",
            "08_account.sql"
    );
    private static final String SET_PLACEHOLDER = "{set}";
    private static final String LIKE_ANY_SUFFIX = "%";

    private final UserRepository userRepository;
    private final SeasonRepository seasonRepository;

    private final LeagueRankingStore leagueRankingStore;
    private final RedisUserCleanManager redisUserCleanManager;
    private final QaFixtureReloadLock reloadLock;

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final DataSource dataSource;
    private final TransactionTemplate transactionTemplate;
    private final Clock clock;

    public QaFixtureManifestResponse reload(QaFixtureSet set) {
        if (!reloadLock.tryAcquire(set)) {
            throw new RestApiException(QA_FIXTURE_RELOAD_IN_PROGRESS);
        }

        try {
            verifyPrerequisites();

            removeFromRedis(findRankMembers(set), findUserIds(set));

            QaFixtureLoadResultDto result = transactionTemplate.execute(status -> deleteAndLoad(set));

            addToRedis(result);

            return QaFixtureManifestResponse.of(
                    set,
                    OffsetDateTime.now(clock).truncatedTo(ChronoUnit.SECONDS),
                    result.personas()
            );
        } finally {
            reloadLock.release(set);
        }
    }

    private void verifyPrerequisites() {
        seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .orElseThrow(() -> new RestApiException(ACTIVE_SEASON_NOT_FOUND));

        Boolean ready = jdbcTemplate.queryForObject(PREREQUISITE_SQL, Map.of(), Boolean.class);
        if (!Boolean.TRUE.equals(ready)) {
            throw new RestApiException(QA_FIXTURE_PREREQUISITE_MISSING);
        }
    }

    private List<Long> findUserIds(QaFixtureSet set) {
        return jdbcTemplate.queryForList(
                FIND_USER_IDS_SQL,
                Map.of("providerIdPattern", set.providerIdPrefix() + LIKE_ANY_SUFFIX),
                Long.class
        );
    }

    private List<QaRankMemberDto> findRankMembers(QaFixtureSet set) {
        return jdbcTemplate.query(
                FIND_RANK_MEMBERS_SQL,
                Map.of("providerIdPattern", set.providerIdPrefix() + LIKE_ANY_SUFFIX),
                (rs, rowNum) -> new QaRankMemberDto(
                        rs.getLong("season_id"),
                        rs.getLong("league_id"),
                        rs.getLong("user_id"),
                        rs.getInt("league_point")
                )
        );
    }

    private void removeFromRedis(
            List<QaRankMemberDto> rankMembers,
            List<Long> userIds
    ) {
        rankMembers.forEach(member -> leagueRankingStore.remove(
                member.seasonId(),
                member.leagueId(),
                member.userId()
        ));
        userIds.forEach(redisUserCleanManager::removeUserKey);
    }

    private QaFixtureLoadResultDto deleteAndLoad(QaFixtureSet set) {
        jdbcTemplate.getJdbcTemplate().execute(SET_LOCAL_TIME_ZONE_SQL);

        List<Long> previousUserIds = findUserIds(set);
        previousUserIds.forEach(userRepository::cleanUserDeletion);
        if (!previousUserIds.isEmpty()) {
            jdbcTemplate.update(DELETE_USER_DAILY_ACTIVITY_SQL, Map.of("userIds", previousUserIds));
        }

        SCRIPT_FILES.forEach(file -> runScript(file, set));

        Map<QaPersona, Long> personaToUserId = findPersonaUserIds(set);
        List<QaPersonaManifestResponse> personas = Arrays.stream(QaPersona.values())
                .map(persona -> QaPersonaManifestResponse.of(
                        persona.getKey(),
                        personaToUserId.get(persona),
                        persona.description(set)
                ))
                .toList();

        return new QaFixtureLoadResultDto(
                personas,
                findRankMembers(set),
                personaToUserId.get(QaPersona.WITHDRAWING)
        );
    }

    private void runScript(
            String file,
            QaFixtureSet set
    ) {
        String script = readScript(file).replace(SET_PLACEHOLDER, set.getKey());
        EncodedResource resource = new EncodedResource(
                new ByteArrayResource(script.getBytes(StandardCharsets.UTF_8)),
                StandardCharsets.UTF_8
        );

        Connection connection = DataSourceUtils.getConnection(dataSource);
        try {
            ScriptUtils.executeSqlScript(connection, resource);
        } finally {
            DataSourceUtils.releaseConnection(connection, dataSource);
        }
    }

    private String readScript(String file) {
        try {
            return new ClassPathResource(SCRIPT_DIRECTORY + file).getContentAsString(StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private Map<QaPersona, Long> findPersonaUserIds(QaFixtureSet set) {
        List<String> providerIds = Arrays.stream(QaPersona.values())
                .map(persona -> persona.providerId(set))
                .toList();

        Map<String, Long> providerIdToUserId = new HashMap<>();
        jdbcTemplate.query(
                FIND_PERSONA_USER_IDS_SQL,
                Map.of("providerIds", providerIds),
                rs -> {
                    providerIdToUserId.put(rs.getString("provider_id"), rs.getLong("id"));
                }
        );

        Map<QaPersona, Long> personaToUserId = new EnumMap<>(QaPersona.class);
        for (QaPersona persona : QaPersona.values()) {
            Long userId = providerIdToUserId.get(persona.providerId(set));
            if (userId == null) {
                throw new IllegalStateException("QA 페르소나가 적재되지 않았습니다: " + persona.getKey());
            }
            personaToUserId.put(persona, userId);
        }
        return personaToUserId;
    }

    private void addToRedis(QaFixtureLoadResultDto result) {
        result.rankMembers().forEach(member -> leagueRankingStore.put(
                member.seasonId(),
                member.leagueId(),
                member.userId(),
                member.leaguePoint()
        ));
        redisUserCleanManager.storeDeletionUser(result.withdrawingUserId());
    }
}
