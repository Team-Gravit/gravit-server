package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.infrastructure.LeagueRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.service.SeasonService;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.domain.UserLeagueRepository;
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
    private final SeasonService seasonService;

    @Transactional(readOnly = true)
    public String getUserLeagueName(Long userId){
        return userLeagueRepository.findUserLeagueNameByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_LEAGUE_NOT_FOUND));
    }

    @Transactional
    public void initUserLeague(Long userId){

        User user = userRepository.findById(userId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        if(userLeagueRepository.existsByUserId(userId)) {
            throw new RestApiException(CustomErrorCode.USER_LEAGUE_CONFLICT);
        }

        League startLeague = leagueRepository.findFirstByOrderBySortOrderAsc().orElseThrow(()-> new RestApiException(CustomErrorCode.LEAGUE_NOT_FOUND));

        Season season = seasonService.getOrCreateActiveSeason();
        userLeagueRepository.save(UserLeague.create(user, season, startLeague));
    }

}
