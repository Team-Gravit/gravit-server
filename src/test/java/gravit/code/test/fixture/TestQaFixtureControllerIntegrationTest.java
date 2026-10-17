package gravit.code.test.fixture;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.support.TCSpringBootTest;
import gravit.code.test.fixture.support.QaFixtureReloadLock;
import gravit.code.test.fixture.support.QaFixtureSet;
import gravit.code.userLeague.infrastructure.LeagueRankScore;
import lombok.extern.slf4j.Slf4j;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import javax.sql.DataSource;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.ACTIVE_SEASON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.QA_FIXTURE_PREREQUISITE_MISSING;
import static gravit.code.global.exception.domain.CustomErrorCode.QA_FIXTURE_RELOAD_IN_PROGRESS;
import static gravit.code.global.exception.domain.CustomErrorCode.QA_FIXTURE_SET_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Slf4j
@TCSpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.flyway.enabled=true",
        "spring.flyway.clean-disabled=false",
        "spring.jpa.hibernate.ddl-auto=none"
})
class TestQaFixtureControllerIntegrationTest {

    private static final String RELOAD_URI = "/api/v1/test/fixtures/qa/reload";
    private static final String AUTO = "auto";
    private static final String MANUAL = "manual";
    private static final List<String> PERSONA_KEYS = List.of(
            "pre-onboarding", "fresh", "learner", "streak", "chapter-almost", "social", "league-edge",
            "mission", "interviewer", "inquirer", "withdrawing", "suspended", "admin"
    );
    private static final int SET_USER_COUNT = 19;
    private static final String FIXED_LOADED_AT = "2025-08-05T12:00:00+09:00";
    private static final long FIXED_PURGE_AT_EPOCH_SECOND = OffsetDateTime.parse("2025-08-12T12:00:00+09:00").toEpochSecond();
    private static final String RANK_KEY_FORMAT = "league:rank:%d:%d";
    private static final String CLEAN_DUE_KEY = "user:clean:due";
    private static final List<String> CONTENT_SEED_LOCATIONS = List.of(
            "classpath:sql/chapter/chapter.sql",
            "classpath:sql/chapter/chapter_track.sql",
            "classpath:sql/league/league.sql",
            "classpath:sql/unit/unit.sql",
            "classpath:sql/unit/unit_track.sql",
            "classpath*:sql/problem/**/*.sql",
            "classpath*:sql/interview/**/*.sql",
            "classpath:sql/sync/resync_sequences.sql"
    );
    private static final String INSERT_SEASONS_SQL = """
            INSERT INTO season (season_key, status, starts_at, ends_at, tz)
            VALUES ('QA-CLOSED', 'CLOSED', now() - INTERVAL '130 days', now() - INTERVAL '10 days', 'Asia/Seoul'),
                   ('QA-ACTIVE', 'ACTIVE', now() - INTERVAL '10 days', now() + INTERVAL '110 days', 'Asia/Seoul')
            """;
    private static final String INSERT_ACTIVE_SEASON_SQL = """
            INSERT INTO season (season_key, status, starts_at, ends_at, tz)
            VALUES ('QA-ACTIVE', 'ACTIVE', now() - INTERVAL '10 days', now() + INTERVAL '110 days', 'Asia/Seoul')
            """;
    private static final String USER_REFERENCE_COLUMNS_SQL = """
            SELECT table_name, column_name
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND column_name IN ('user_id', 'follower_id', 'followee_id', 'actor_id', 'author_id', 'admin_id')
            ORDER BY table_name, column_name
            """;
    private static final Map<String, String> ORPHAN_ROW_SQLS = Map.of(
            "interview_session_topic", "SELECT count(*) FROM interview_session_topic t WHERE NOT EXISTS (SELECT 1 FROM interview_session s WHERE s.id = t.session_id)",
            "interview_answer", "SELECT count(*) FROM interview_answer a WHERE NOT EXISTS (SELECT 1 FROM interview_session s WHERE s.id = a.session_id)",
            "interview_feedback", "SELECT count(*) FROM interview_feedback f WHERE NOT EXISTS (SELECT 1 FROM interview_answer a WHERE a.id = f.answer_id)",
            "user_feed", "SELECT count(*) FROM user_feed uf WHERE NOT EXISTS (SELECT 1 FROM social_feed sf WHERE sf.id = uf.feed_id)"
    );

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private DataSource dataSource;

    @Autowired
    private Flyway flyway;

    @Autowired
    private QaFixtureReloadLock reloadLock;

    @Autowired
    @Qualifier("rankingRedisTemplate")
    private RedisTemplate<String, String> rankingRedisTemplate;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    private void 마이그레이션과_기준_데이터를_적재한다() throws IOException {
        flyway.clean();
        flyway.migrate();

        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        List<Resource> seeds = new ArrayList<>();
        for (String location : CONTENT_SEED_LOCATIONS) {
            Resource[] resources = resolver.getResources(location);
            Arrays.sort(resources, Comparator.comparing(Resource::getDescription));
            seeds.addAll(Arrays.asList(resources));
        }
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator(seeds.toArray(Resource[]::new));
        populator.setSqlScriptEncoding(StandardCharsets.UTF_8.name());
        populator.execute(dataSource);

        jdbcTemplate.update(INSERT_SEASONS_SQL);
    }

    private JsonNode 재적재한다(String set) throws Exception {
        String body = mockMvc.perform(post(RELOAD_URI).param("set", set))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString(StandardCharsets.UTF_8);
        return objectMapper.readTree(body);
    }

    private long 유저_id(
            String set,
            String key
    ) {
        return jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE provider_id = ?",
                Long.class,
                "qa-persona-" + set + "-" + key
        );
    }

    private List<Long> 세트_유저_id(String set) {
        return jdbcTemplate.queryForList(
                "SELECT id FROM users WHERE provider_id LIKE ? ORDER BY id",
                Long.class,
                "qa-persona-" + set + "-%"
        );
    }

    private long 건수(
            String sql,
            Object... args
    ) {
        return jdbcTemplate.queryForObject(sql, Long.class, args);
    }

    private Map<String, Long> 매니페스트_userId(JsonNode manifest) {
        Map<String, Long> personaKeyToUserId = new HashMap<>();
        manifest.get("personas").forEach(persona ->
                personaKeyToUserId.put(persona.get("personaKey").asText(), persona.get("userId").asLong()));
        return personaKeyToUserId;
    }

    private List<Map<String, Object>> 랭킹_대상(String set) {
        return jdbcTemplate.queryForList("""
                SELECT ul.season_id, ul.league_id, ul.user_id, ul.league_point
                FROM user_league ul
                JOIN users u ON u.id = ul.user_id
                WHERE u.provider_id LIKE ?
                  AND u.deleted_at IS NULL
                """, "qa-persona-" + set + "-%");
    }

    private Double 랭킹_점수(
            long seasonId,
            long leagueId,
            long userId
    ) {
        return rankingRedisTemplate.opsForZSet().score(RANK_KEY_FORMAT.formatted(seasonId, leagueId), String.valueOf(userId));
    }

    private boolean 랭킹에_있다(long userId) {
        return rankingRedisTemplate.keys("league:rank:*").stream()
                .anyMatch(key -> rankingRedisTemplate.opsForZSet().score(key, String.valueOf(userId)) != null);
    }

    @Nested
    @DisplayName("세트를 처음 적재할 때")
    class FirstReload {

        @Test
        void 페르소나_13개의_매니페스트를_반환한다() throws Exception {
            // given
            마이그레이션과_기준_데이터를_적재한다();

            // when
            long startedAt = System.nanoTime();
            JsonNode manifest = 재적재한다(AUTO);
            log.info("QA 페르소나 재적재 소요: {}ms", (System.nanoTime() - startedAt) / 1_000_000);

            // then
            List<String> personaKeys = new ArrayList<>();
            manifest.get("personas").forEach(persona -> personaKeys.add(persona.get("personaKey").asText()));
            Map<String, Long> personaKeyToUserId = 매니페스트_userId(manifest);

            assertSoftly(softly -> {
                softly.assertThat(manifest.get("set").asText()).isEqualTo(AUTO);
                softly.assertThat(manifest.get("loadedAt").asText()).isEqualTo(FIXED_LOADED_AT);
                softly.assertThat(personaKeys).containsExactlyElementsOf(PERSONA_KEYS);
                PERSONA_KEYS.forEach(key ->
                        softly.assertThat(personaKeyToUserId.get(key)).as(key).isEqualTo(유저_id(AUTO, key)));
                softly.assertThat(manifest.get("personas").get(0).get("description").asText()).isNotBlank();
                softly.assertThat(세트_유저_id(AUTO)).hasSize(SET_USER_COUNT);
            });
        }

        @Test
        void 페르소나별_상태가_명세와_같다() throws Exception {
            // given
            마이그레이션과_기준_데이터를_적재한다();

            // when
            재적재한다(AUTO);

            // then
            long preOnboarding = 유저_id(AUTO, "pre-onboarding");
            long fresh = 유저_id(AUTO, "fresh");
            long learner = 유저_id(AUTO, "learner");
            long streak = 유저_id(AUTO, "streak");
            long chapterAlmost = 유저_id(AUTO, "chapter-almost");
            long social = 유저_id(AUTO, "social");
            long leagueEdge = 유저_id(AUTO, "league-edge");
            long mission = 유저_id(AUTO, "mission");
            long interviewer = 유저_id(AUTO, "interviewer");
            long inquirer = 유저_id(AUTO, "inquirer");
            long withdrawing = 유저_id(AUTO, "withdrawing");
            long suspended = 유저_id(AUTO, "suspended");
            long admin = 유저_id(AUTO, "admin");

            assertSoftly(softly -> {
                softly.assertThat(건수("SELECT count(*) FROM users WHERE id = ? AND NOT is_onboarded", preOnboarding)).isEqualTo(1);
                softly.assertThat(건수("""
                        SELECT (SELECT count(*) FROM learning WHERE user_id = ?)
                             + (SELECT count(*) FROM user_mission WHERE user_id = ?)
                             + (SELECT count(*) FROM user_league WHERE user_id = ?)
                        """, preOnboarding, preOnboarding, preOnboarding)).isZero();

                softly.assertThat(건수("""
                        SELECT count(*)
                        FROM users u
                        JOIN learning lr ON lr.user_id = u.id
                        JOIN user_mission um ON um.user_id = u.id
                        JOIN user_league ul ON ul.user_id = u.id
                        WHERE u.id = ? AND u.xp = 0 AND ul.league_point = 0 AND um.progress_count = 0
                        """, fresh)).isEqualTo(1);

                softly.assertThat(건수("""
                        SELECT count(*) FROM lesson_submission
                        WHERE user_id = ? AND created_at >= (now() AT TIME ZONE 'Asia/Seoul') - INTERVAL '14 days'
                        """, learner)).isEqualTo(10);
                softly.assertThat(건수("SELECT count(*) FROM problem_submission WHERE user_id = ? AND NOT is_correct", learner)).isEqualTo(6);
                softly.assertThat(건수("SELECT count(*) FROM problem_submission WHERE user_id = ? AND is_correct", learner)).isPositive();
                softly.assertThat(건수("SELECT count(*) FROM wrong_answered_note WHERE user_id = ? AND resolved_at IS NULL", learner)).isEqualTo(6);
                softly.assertThat(건수("SELECT count(*) FROM bookmark WHERE user_id = ?", learner)).isEqualTo(3);
                softly.assertThat(건수("SELECT count(*) FROM daily_learning_record WHERE user_id = ?", learner)).isEqualTo(10);
                softly.assertThat(건수("SELECT consecutive_solved_days FROM learning WHERE user_id = ?", learner)).isEqualTo(4);

                softly.assertThat(건수("SELECT consecutive_solved_days FROM learning WHERE user_id = ? AND NOT today_solved", streak)).isEqualTo(6);
                softly.assertThat(건수("SELECT count(*) FROM daily_learning_record WHERE user_id = ?", streak)).isEqualTo(6);

                softly.assertThat(건수("SELECT count(DISTINCT lesson_id) FROM lesson_submission WHERE user_id = ?", chapterAlmost))
                        .isEqualTo(건수("SELECT count(*) FROM lesson l JOIN unit u ON u.id = l.unit_id WHERE u.chapter_id = 1") - 1);

                softly.assertThat(건수("SELECT count(*) FROM friends WHERE follower_id = ? OR followee_id = ?", social, social)).isEqualTo(3);
                softly.assertThat(건수("SELECT count(*) FROM user_feed WHERE user_id = ?", social)).isEqualTo(2);
                softly.assertThat(건수("SELECT count(*) FROM congratulation WHERE user_id = ? OR actor_id = ?", social, social)).isEqualTo(2);
                softly.assertThat(건수("SELECT count(*) FROM notification WHERE user_id = ?", social)).isEqualTo(5);

                softly.assertThat(건수("""
                        SELECT count(*) FROM user_league ul JOIN league l ON l.id = ul.league_id
                        WHERE ul.user_id = ? AND ul.league_point = 615 AND l.name = '실버 2'
                        """, leagueEdge)).isEqualTo(1);
                softly.assertThat(건수("SELECT count(*) FROM user_league_history WHERE user_id = ?", leagueEdge)).isEqualTo(1);

                softly.assertThat(건수("""
                        SELECT um.progress_count FROM user_mission um JOIN mission m ON m.id = um.mission_id
                        WHERE um.user_id = ? AND m.code = 'COMPLETE_LESSONS_TWO' AND um.completed_at IS NULL
                        """, mission)).isEqualTo(1);
                softly.assertThat(건수("""
                        SELECT count(*) FROM lesson_submission
                        WHERE user_id = ?
                          AND created_at BETWEEN (now() AT TIME ZONE 'Asia/Seoul') - INTERVAL '1 minute'
                                             AND (now() AT TIME ZONE 'Asia/Seoul')
                        """, mission)).as("오늘 제출 시각은 KST 벽시계").isEqualTo(1);

                softly.assertThat(건수("SELECT count(DISTINCT status) FROM interview_session WHERE user_id = ?", interviewer)).isEqualTo(4);
                softly.assertThat(건수("""
                        SELECT accuracy_score + delivery_score FROM interview_session
                        WHERE user_id = ? AND status = 'COMPLETED'
                        """, interviewer)).isEqualTo(57);
                softly.assertThat(건수("""
                        SELECT count(*) FROM interview_feedback f
                        JOIN interview_answer a ON a.id = f.answer_id
                        JOIN interview_session s ON s.id = a.session_id
                        WHERE s.user_id = ?
                        """, interviewer)).isEqualTo(5);

                softly.assertThat(건수("SELECT count(*) FROM inquiry WHERE user_id = ?", inquirer)).isEqualTo(2);
                softly.assertThat(건수("""
                        SELECT count(*) FROM inquiry_answer ia JOIN inquiry i ON i.id = ia.inquiry_id
                        WHERE i.user_id = ? AND ia.admin_id = ?
                        """, inquirer, admin)).isEqualTo(1);

                softly.assertThat(건수("""
                        SELECT count(*) FROM users
                        WHERE id = ? AND status = 'DELETED' AND deleted_at IS NOT NULL AND handle IS NULL
                        """, withdrawing)).isEqualTo(1);
                softly.assertThat(건수("SELECT count(*) FROM users WHERE id = ? AND status = 'SUSPENDED'", suspended)).isEqualTo(1);
                softly.assertThat(건수("SELECT count(*) FROM users WHERE id = ? AND role = 'ADMIN'", admin)).isEqualTo(1);
            });
        }

        @Test
        void 리그_랭킹과_탈퇴_정리_예약을_Redis에_반영한다() throws Exception {
            // given
            마이그레이션과_기준_데이터를_적재한다();

            // when
            재적재한다(AUTO);

            // then
            List<Map<String, Object>> rankMembers = 랭킹_대상(AUTO);
            long withdrawing = 유저_id(AUTO, "withdrawing");

            assertSoftly(softly -> {
                softly.assertThat(rankMembers).hasSize(SET_USER_COUNT - 2);
                rankMembers.forEach(member -> {
                    long userId = ((Number) member.get("user_id")).longValue();
                    softly.assertThat(랭킹_점수(
                            ((Number) member.get("season_id")).longValue(),
                            ((Number) member.get("league_id")).longValue(),
                            userId
                    )).isEqualTo(LeagueRankScore.encode(((Number) member.get("league_point")).intValue(), userId));
                });
                softly.assertThat(랭킹에_있다(withdrawing)).isFalse();
                softly.assertThat(redisTemplate.opsForZSet().score(CLEAN_DUE_KEY, String.valueOf(withdrawing)))
                        .isEqualTo((double) FIXED_PURGE_AT_EPOCH_SECOND);
            });
        }
    }

    @Nested
    @DisplayName("같은 세트를 다시 적재할 때")
    class ReloadSameSet {

        @Test
        void 이전_유저를_DB와_Redis에서_지우고_새로_적재한다() throws Exception {
            // given
            마이그레이션과_기준_데이터를_적재한다();
            재적재한다(AUTO);
            List<Long> previousUserIds = 세트_유저_id(AUTO);
            long previousWithdrawing = 유저_id(AUTO, "withdrawing");

            // when
            재적재한다(AUTO);

            // then
            List<Long> currentUserIds = 세트_유저_id(AUTO);

            assertSoftly(softly -> {
                softly.assertThat(currentUserIds).hasSize(SET_USER_COUNT).doesNotContainAnyElementsOf(previousUserIds);
                previousUserIds.forEach(userId -> softly.assertThat(랭킹에_있다(userId)).as("이전 랭킹 멤버 " + userId).isFalse());
                softly.assertThat(redisTemplate.opsForZSet().score(CLEAN_DUE_KEY, String.valueOf(previousWithdrawing))).isNull();
                softly.assertThat(redisTemplate.opsForZSet().score(CLEAN_DUE_KEY, String.valueOf(유저_id(AUTO, "withdrawing")))).isNotNull();
                softly.assertThat(랭킹_대상(AUTO)).hasSize(SET_USER_COUNT - 2);
            });
        }

        @Test
        void 이전_세트_userId를_참조하는_행과_하위_고아_행이_남지_않는다() throws Exception {
            // given
            마이그레이션과_기준_데이터를_적재한다();
            재적재한다(AUTO);
            jdbcTemplate.update(
                    "INSERT INTO user_daily_activity (user_id, activity_date) VALUES (?, current_date)",
                    유저_id(AUTO, "fresh")
            );
            String previousUserIds = 세트_유저_id(AUTO).stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining(", "));

            // when
            재적재한다(AUTO);

            // then
            List<Map<String, Object>> userReferenceColumns = jdbcTemplate.queryForList(USER_REFERENCE_COLUMNS_SQL);

            assertSoftly(softly -> {
                softly.assertThat(userReferenceColumns).isNotEmpty();
                userReferenceColumns.forEach(column -> {
                    String table = (String) column.get("table_name");
                    String columnName = (String) column.get("column_name");
                    softly.assertThat(건수("SELECT count(*) FROM %s WHERE %s IN (%s)".formatted(table, columnName, previousUserIds)))
                            .as(table + "." + columnName)
                            .isZero();
                });
                ORPHAN_ROW_SQLS.forEach((table, sql) -> softly.assertThat(건수(sql)).as(table + " 고아 행").isZero());
            });
        }
    }

    @Nested
    @DisplayName("다른 세트를 적재할 때")
    class ReloadOtherSet {

        @Test
        void 이미_적재한_세트의_데이터는_그대로_둔다() throws Exception {
            // given
            마이그레이션과_기준_데이터를_적재한다();
            재적재한다(MANUAL);
            List<Long> manualUserIds = 세트_유저_id(MANUAL);
            long manualLearnerSubmissions = 건수("SELECT count(*) FROM lesson_submission WHERE user_id = ?", 유저_id(MANUAL, "learner"));

            // when
            재적재한다(AUTO);

            // then
            assertSoftly(softly -> {
                softly.assertThat(세트_유저_id(MANUAL)).containsExactlyElementsOf(manualUserIds);
                softly.assertThat(건수("SELECT count(*) FROM lesson_submission WHERE user_id = ?", 유저_id(MANUAL, "learner")))
                        .isEqualTo(manualLearnerSubmissions);
                softly.assertThat(랭킹에_있다(유저_id(MANUAL, "fresh"))).isTrue();
                softly.assertThat(redisTemplate.opsForZSet().score(CLEAN_DUE_KEY, String.valueOf(유저_id(MANUAL, "withdrawing")))).isNotNull();
                softly.assertThat(세트_유저_id(AUTO)).hasSize(SET_USER_COUNT).doesNotContainAnyElementsOf(manualUserIds);
            });
        }
    }

    @Nested
    @DisplayName("적재할 수 없을 때")
    class ReloadRejected {

        @Test
        void 같은_세트가_적재_중이면_409를_반환한다() throws Exception {
            // given
            reloadLock.tryAcquire(QaFixtureSet.AUTO);

            try {
                // when & then
                mockMvc.perform(post(RELOAD_URI).param("set", AUTO))
                        .andExpect(status().isConflict())
                        .andExpect(jsonPath("$.error").value(QA_FIXTURE_RELOAD_IN_PROGRESS.getCode()));
            } finally {
                reloadLock.release(QaFixtureSet.AUTO);
            }
        }

        @Test
        void 지원하지_않는_세트면_400을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(post(RELOAD_URI).param("set", "prod"))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(QA_FIXTURE_SET_INVALID.getCode()));
        }

        @Test
        void ACTIVE_시즌이_없으면_404를_반환한다() throws Exception {
            // when & then
            mockMvc.perform(post(RELOAD_URI).param("set", AUTO))
                    .andExpect(status().isNotFound())
                    .andExpect(jsonPath("$.error").value(ACTIVE_SEASON_NOT_FOUND.getCode()));
        }

        @Test
        void 기준_데이터가_없으면_409를_반환하고_아무것도_적재하지_않는다() throws Exception {
            // given
            jdbcTemplate.update(INSERT_ACTIVE_SEASON_SQL);

            // when & then
            mockMvc.perform(post(RELOAD_URI).param("set", AUTO))
                    .andExpect(status().isConflict())
                    .andExpect(jsonPath("$.error").value(QA_FIXTURE_PREREQUISITE_MISSING.getCode()));
            assertThat(세트_유저_id(AUTO)).isEmpty();
        }
    }
}
