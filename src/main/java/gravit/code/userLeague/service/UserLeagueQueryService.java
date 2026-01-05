package gravit.code.userLeague.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.response.LeagueRankRow;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserLeagueQueryService {

    private final UserRepository userRepository;
    private final UserLeagueRepository userLeagueRepository;

    @Transactional(readOnly = true)
    public MyLeagueRankWithProfileResponse getMyLeagueRankWithProfile(long userId) {

        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        return userLeagueRepository.findLeagueRankAndProfile(userId);
    }

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRow> findLeagueRanking(
            long leagueId,
            int page
    ){
        int safePage = Math.max(0, page);
        return userLeagueRepository.findLeagueRanking(leagueId, safePage);
    }

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRow> findLeagueRankingByUser(
            long userId,
            int page
    ){
        int safePage = Math.max(0, page);

        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        return userLeagueRepository.findLeagueRankingByUser(userId, safePage);
    }
}
