package gravit.code.userLeague.repository.custom;


import gravit.code.global.dto.response.SliceResponse;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;

public interface LeagueRankingQueryRepository {
    SliceResponse<LeagueRankRowDto> findLeagueRanking(
            long leagueId,
            int page
    );
    SliceResponse<LeagueRankRowDto> findLeagueRankingByUser(
            long userId,
            int page
    );
}
