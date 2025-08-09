package gravit.code.domain.userLeague.service;

import gravit.code.domain.league.domain.League;
import gravit.code.domain.league.infrastructure.LeagueRepository;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.userLeague.domain.UserLeague;
import gravit.code.domain.userLeague.domain.UserLeagueRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLeagueService {

    private final UserLeagueRepository userLeagueRepository;
    private final UserRepository userRepository;
    private final LeagueRepository leagueRepository;

    public String getUserLeagueName(Long userId){
        return userLeagueRepository.findUserLeagueNameByUserId(userId);
    }

    @Transactional
    public void initUserLeague(Long userId){

        User user = userRepository.findById(userId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        log.info("initUserLeague : 유저 리그 초기화");
        if(userLeagueRepository.existsByUserId(userId)) {
            throw new RestApiException(CustomErrorCode.USER_LEAGUE_CONFLICT);
        }

        League startLeague = leagueRepository.findFirstByOrderBySortOrderAsc().orElseThrow(()-> new RestApiException(CustomErrorCode.LEAGUE_NOT_FOUND));

        log.info("initUserLeague : 유저 리그 생성");
        userLeagueRepository.save(UserLeague.create(user, startLeague));
    }

}
