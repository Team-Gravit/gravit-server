package gravit.code.domain.userLeague.service;

import gravit.code.domain.league.infrastructure.LeagueRepository;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.userLeague.domain.UserLeagueRepository;
import gravit.code.domain.userLeague.dto.response.LeagueRankRow;
import gravit.code.domain.userLeague.infrastructure.UserLeagueRankQueryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLeagueRankService {

    private final UserLeagueRankQueryRepository rankQueryRepository;

    @Transactional(readOnly = true)
    public List<LeagueRankRow> getLeagueRanks(Long leagueId, int page){
        return rankQueryRepository.findLeagueRanks(leagueId, page);
    }

    @Transactional(readOnly = true)
    public List<LeagueRankRow> getUserLeagueRanks(Long userId, int page){
        return rankQueryRepository.findUserLeagueRanks(userId, page);
    }

}
