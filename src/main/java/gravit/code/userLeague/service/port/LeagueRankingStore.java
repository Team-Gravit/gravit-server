package gravit.code.userLeague.service.port;

import gravit.code.userLeague.dto.internal.LeagueRankEntry;

import java.util.List;
import java.util.Optional;

public interface LeagueRankingStore {

    void put(
            long seasonId,
            long leagueId,
            long userId,
            int leaguePoint
    );

    void move(
            long seasonId,
            long fromLeagueId,
            long toLeagueId,
            long userId,
            int leaguePoint
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

    List<LeagueRankEntry> findPage(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    );

    void replaceAll(
            long seasonId,
            List<LeagueRankEntry> entries
    );

    void deleteSeason(long seasonId);

    boolean hasRanking(long seasonId);

    long countRanked(long seasonId);
}
