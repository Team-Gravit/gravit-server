package gravit.code.userLeague.service;

import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;

public interface MyLeagueProfileQueryRepository {
    MyLeagueRankWithProfileResponse findLeagueRankAndProfile(Long userId);
}
