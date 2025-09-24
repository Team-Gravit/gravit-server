package gravit.code.userLeague.service;


import gravit.code.global.dto.SliceResponse;
import gravit.code.userLeague.dto.response.LeagueRankRow;

public interface LeagueRankingQueryRepository {
    SliceResponse<LeagueRankRow> findLeagueRanking(long leagueId, int page);
    SliceResponse<LeagueRankRow> findLeagueRankingByUser(long userId, int page);
}
