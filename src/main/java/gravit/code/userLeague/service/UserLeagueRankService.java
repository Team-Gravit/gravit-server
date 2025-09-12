package gravit.code.userLeague.service;

import gravit.code.userLeague.dto.response.LeagueRankRow;
import gravit.code.userLeague.infrastructure.UserLeagueRankQueryRepository;
import gravit.code.global.dto.SliceResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLeagueRankService {

    private final UserLeagueRankQueryRepository rankQueryRepository;

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRow> getLeagueRanks(Long leagueId, int page){
        int safePage = Math.max(0, page);
        return rankQueryRepository.findLeagueRanks(leagueId, safePage);
    }

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRow> getUserLeagueRanks(Long userId, int page){
        int safePage = Math.max(0, page);
        return rankQueryRepository.findUserLeagueRanks(userId, safePage);
    }

}
