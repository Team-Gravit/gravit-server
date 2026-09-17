package gravit.code.userLeague.service.port;

import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
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

    List<LeagueRankEntryDto> findPage(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    );

    void replaceAll(
            long seasonId,
            List<LeagueRankEntryDto> entries
    );

    void deleteSeason(long seasonId);

    boolean hasRanking(long seasonId);

    long countRanked(long seasonId);
}
