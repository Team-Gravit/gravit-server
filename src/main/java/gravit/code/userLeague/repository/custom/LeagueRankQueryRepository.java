package gravit.code.userLeague.repository.custom;

import gravit.code.userLeague.dto.internal.LeagueRankEntryDto;
import java.util.List;

public interface LeagueRankQueryRepository {

    int findRankInLeague(
            long seasonId,
            long leagueId,
            int leaguePoint,
            long userId
    );

    List<LeagueRankEntryDto> findRankPageInLeague(
            long seasonId,
            long leagueId,
            int offset,
            int limit
    );
}
