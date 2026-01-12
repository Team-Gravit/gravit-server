package gravit.code.userLeague.repository.custom;

import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;

public interface MyLeagueProfileQueryRepository {
    MyLeagueRankWithProfileResponse findLeagueRankAndProfile(Long userId);
}
