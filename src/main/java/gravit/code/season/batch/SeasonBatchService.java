package gravit.code.season.batch;

import gravit.code.league.domain.League;
import gravit.code.league.infrastructure.LeagueRepository;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.season.calendar.SeasonCalendar;
import gravit.code.season.domain.Season;
import gravit.code.season.infrastructure.SeasonRepository;
import gravit.code.userLeague.domain.UserLeagueRepository;
import gravit.code.userLeagueHistory.infrastructure.UserLeagueHistoryRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.RecoverableDataAccessException;
import org.springframework.dao.TransientDataAccessException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.ZoneId;


@Service
@RequiredArgsConstructor
@Slf4j
public class SeasonBatchService {
    private final SeasonRepository seasonRepository;
    private final UserLeagueHistoryRepository historyRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final LeagueRepository leagueRepository;
    private final SeasonClosedCache seasonClosedCache;


    @Retryable(
            retryFor = {TransientDataAccessException.class, RecoverableDataAccessException.class, SQLException.class},
            backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    @Transactional
    public void finalizeAndRolloverWeekly(){
        // 닫을 시즌 확정 , 락
        LocalDateTime nowKst = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        Season currentSeason = seasonRepository.findCloseableActiveByNowForUpdate(nowKst).orElseThrow(()-> new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND));
        currentSeason.finalizing();

        // 히스토리, UserLeague 스냅샷
        historyRepository.deleteBySeasonId(currentSeason); // 멱등성 보장
        int snap = historyRepository.insertFromCurrent(currentSeason.getId());

        // 다음 시즌 확보
        LocalDateTime nextStartsAt = currentSeason.getEndsAt();
        LocalDateTime nextEndsAt = nextStartsAt.plusWeeks(1);
        Season nextSeason = seasonRepository.findPrepByStartingAt(nextStartsAt).orElseGet(()->
                seasonRepository.save(Season.prep(SeasonCalendar.isoWeekKey(nextStartsAt.toLocalDate()), nextStartsAt, nextEndsAt))
        );

        // UserLeague 초기화 및 시즌 변경
        League league = leagueRepository.findFirstByOrderBySortOrderAsc().orElseThrow(()-> new RestApiException(CustomErrorCode.LEAGUE_NOT_FOUND));
        int inits = userLeagueRepository.resetAllForNextSeason(currentSeason, nextSeason, league);
        log.info("히스토리 스냅샷 로우 수: {},  유저 리그 롤오버 로우 수 = {}", snap, inits);

        nextSeason.activate();
        currentSeason.close();

        // 전 시즌 id 캐싱
        seasonClosedCache.setLastClosedSeasonId(currentSeason.getId());
    }
}
