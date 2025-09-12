package gravit.code.league.service;

import gravit.code.league.domain.League;
import gravit.code.league.dto.response.LeagueResponse;
import gravit.code.league.infrastructure.LeagueRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class LeagueService {

    private final LeagueRepository leagueRepository;

    public LeagueResponse getLeague(Long leagueId) {
        League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RestApiException(CustomErrorCode.LEAGUE_NOT_FOUND));
        return LeagueResponse.from(league);
    }
}
