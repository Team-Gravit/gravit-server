package gravit.code.userLeague.service.port;

import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface LeagueRankingStore {

    void put(
            long seasonId,
            long leagueId,
            long userId,
            int leaguePoint
    );

    boolean place(
            long seasonId,
            Collection<Long> leagueIds,
            long leagueId,
            long userId,
            int leaguePoint
    );

    void evict(
            long seasonId,
            Collection<Long> leagueIds,
            long userId
    );

    void remove(
            long seasonId,
            long leagueId,
            long userId
    );

    Optional<Integer> findRank(
            long seasonId,
            long leagueId,
            long userId
    );

    List<LeagueRankEntryDto> findPage(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    );

    Map<Long, Integer> findLeaguePoints(
            long seasonId,
            long leagueId,
            List<Long> userIds
    );

    void replaceAll(
            long seasonId,
            List<LeagueRankEntryDto> entries
    );

    void replaceLeague(
            long seasonId,
            long leagueId,
            List<LeagueRankEntryDto> entries
    );

    void deleteSeason(long seasonId);

    boolean hasRanking(long seasonId);

    long countRanked(long seasonId);

    long countRanked(
            long seasonId,
            long leagueId
    );

    void markReady(long seasonId);

    boolean isReady(long seasonId);
}
