package gravit.code.userLeague.support;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import io.github.resilience4j.bulkhead.Bulkhead;
import io.github.resilience4j.bulkhead.BulkheadFullException;
import io.github.resilience4j.circuitbreaker.CallNotPermittedException;
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.QueryTimeoutException;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.data.redis.RedisSystemException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import java.util.function.Supplier;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_RANKING_TEMPORARILY_UNAVAILABLE;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankFinder {

    private static final String FIND_RANK_OPERATION = "단건 순위 조회";
    private static final String FIND_PAGE_OPERATION = "순위 페이지 조회";

    private final UserLeagueRepository userLeagueRepository;

    private final LeagueRankingStore leagueRankingStore;

    private final CircuitBreaker leagueRankingStoreCircuitBreaker;
    private final Bulkhead leagueRankDatabaseBulkhead;

    public int findRank(
            long seasonId,
            long leagueId,
            long userId,
            int leaguePoint
    ) {
        Optional<Optional<Integer>> stored = fromStore(
                FIND_RANK_OPERATION,
                seasonId,
                leagueId,
                () -> leagueRankingStore.findRank(seasonId, leagueId, userId)
        );

        if (stored.isPresent() && stored.get().isEmpty()) {
            log.warn("랭킹 저장소에 순위가 없어 DB로 폴백: seasonId={}, leagueId={}, userId={}", seasonId, leagueId, userId);
        }

        return stored.flatMap(Function.identity())
                .orElseGet(() -> fromDatabase(
                        FIND_RANK_OPERATION,
                        seasonId,
                        leagueId,
                        () -> userLeagueRepository.findRankInLeague(seasonId, leagueId, leaguePoint, userId)
                ));
    }

    private <T> Optional<T> fromStore(
            String operation,
            long seasonId,
            long leagueId,
            Supplier<T> query
    ) {
        try {
            return Optional.of(leagueRankingStoreCircuitBreaker.executeSupplier(query));
        } catch (CallNotPermittedException e) {
            return Optional.empty();
        } catch (RedisConnectionFailureException | RedisSystemException | QueryTimeoutException e) {
            log.error("랭킹 저장소 장애로 DB 폴백: operation={}, seasonId={}, leagueId={}", operation, seasonId, leagueId, e);

            return Optional.empty();
        }
    }

    private <T> T fromDatabase(
            String operation,
            long seasonId,
            long leagueId,
            Supplier<T> query
    ) {
        try {
            return leagueRankDatabaseBulkhead.executeSupplier(query);
        } catch (BulkheadFullException e) {
            log.warn("랭킹 DB 폴백 상한 초과로 거절: operation={}, seasonId={}, leagueId={}", operation, seasonId, leagueId);

            throw new RestApiException(LEAGUE_RANKING_TEMPORARILY_UNAVAILABLE);
        }
    }

    public List<LeagueRankEntryDto> findPage(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    ) {
        return fromStore(
                FIND_PAGE_OPERATION,
                seasonId,
                leagueId,
                () -> leagueRankingStore.findPage(seasonId, leagueId, offset, limit)
        ).orElseGet(() -> fromDatabase(
                FIND_PAGE_OPERATION,
                seasonId,
                leagueId,
                () -> userLeagueRepository.findRankPageInLeague(seasonId, leagueId, offset, limit)
        ));
    }
}
