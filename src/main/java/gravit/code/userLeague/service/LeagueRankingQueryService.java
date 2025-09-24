package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.UserRepository;
import gravit.code.userLeague.dto.response.LeagueRankRow;
import gravit.code.userLeague.infrastructure.JdbcLeagueRankingQueryRepository;
import gravit.code.global.dto.SliceResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class LeagueRankingQueryService {

    private final LeagueRankingQueryRepository rankingQueryRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRow> findLeagueRanking(long leagueId, int page){
        int safePage = Math.max(0, page);
        return rankingQueryRepository.findLeagueRanking(leagueId, safePage);
    }

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRow> findLeagueRankingByUser(long userId, int page){
        int safePage = Math.max(0, page);

        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        return rankingQueryRepository.findLeagueRankingByUser(userId, safePage);
    }

}
