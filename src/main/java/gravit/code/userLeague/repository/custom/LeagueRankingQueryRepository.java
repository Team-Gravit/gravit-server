package gravit.code.userLeague.repository.custom;


import gravit.code.global.dto.response.SliceResponse;
import gravit.code.userLeague.dto.response.LeagueRankRow;

public interface LeagueRankingQueryRepository {
    SliceResponse<LeagueRankRow> findLeagueRanking(
            long leagueId,
            int page
    );
    SliceResponse<LeagueRankRow> findLeagueRankingByUser(
            long userId,
            int page
    );
}
