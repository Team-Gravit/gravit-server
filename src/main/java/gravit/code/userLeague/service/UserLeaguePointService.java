package gravit.code.userLeague.service;

import gravit.code.league.domain.League;
import gravit.code.league.infrastructure.LeagueRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.domain.UserLeagueRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLeaguePointService {
    private final UserLeagueRepository userLeagueRepository;
    private final LeagueRepository leagueRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePoints(
            Long userId,
            int points,
            int accuracy
    ) {
        UserLeague userLeague = userLeagueRepository.findByUserId(userId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_LEAGUE_NOT_FOUND));

        int updatedLp = userLeague.addLeaguePoints((int) Math.round(points * accuracy * 0.01));
        League league = leagueRepository.findByLpBetween(updatedLp).orElseThrow(() -> new RestApiException(CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT));

        userLeague.updateLeagueIfDifferent(league);
    }
}
