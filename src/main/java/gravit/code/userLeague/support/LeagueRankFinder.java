package gravit.code.userLeague.support;

import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.QueryTimeoutException;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.data.redis.RedisSystemException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.function.Supplier;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankFinder {

    private static final String FIND_RANK_OPERATION = "단건 순위 조회";
    private static final String FIND_PAGE_OPERATION = "순위 페이지 조회";

    private final UserLeagueRepository userLeagueRepository;

    private final LeagueRankingStore leagueRankingStore;

    public int findRank(
            long seasonId,
            long leagueId,
            long userId,
            int leaguePoint
    ) {
        return withFallback(
                FIND_RANK_OPERATION,
                seasonId,
                leagueId,
                () -> leagueRankingStore.findRank(seasonId, leagueId, userId)
                        .orElseGet(() -> findRankFromDatabase(seasonId, leagueId, userId, leaguePoint)),
                () -> userLeagueRepository.findRankInLeague(seasonId, leagueId, leaguePoint, userId)
        );
    }

    public List<LeagueRankEntry> findPage(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    ) {
        return withFallback(
                FIND_PAGE_OPERATION,
                seasonId,
                leagueId,
                () -> leagueRankingStore.findPage(seasonId, leagueId, offset, limit),
                () -> userLeagueRepository.findRankPageInLeague(seasonId, leagueId, offset, limit)
        );
    }

    private <T> T withFallback(
            String operation,
            long seasonId,
            long leagueId,
            Supplier<T> fromStore,
            Supplier<T> fromDatabase
    ) {
        try {
            return fromStore.get();
        } catch (RedisConnectionFailureException | RedisSystemException | QueryTimeoutException e) {
            log.error("랭킹 저장소 장애로 DB 폴백: operation={}, seasonId={}, leagueId={}", operation, seasonId, leagueId, e);

            return fromDatabase.get();
        }
    }

    private int findRankFromDatabase(
            long seasonId,
            long leagueId,
            long userId,
            int leaguePoint
    ) {
        log.warn("랭킹 저장소에 순위가 없어 DB로 폴백: seasonId={}, leagueId={}, userId={}", seasonId, leagueId, userId);

        return userLeagueRepository.findRankInLeague(seasonId, leagueId, leaguePoint, userId);
    }
}
