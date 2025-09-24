package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.UserRepository;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.infrastructure.JdbMyLeagueProfileQueryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class MyLeagueProfileQueryService {
    private final UserRepository userRepository;
    private final MyLeagueProfileQueryRepository myLeagueProfileQueryRepository;

    public MyLeagueRankWithProfileResponse getMyLeagueRankWithProfile(long userId) {

        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        return myLeagueProfileQueryRepository.findLeagueRankAndProfile(userId);
    }

}
