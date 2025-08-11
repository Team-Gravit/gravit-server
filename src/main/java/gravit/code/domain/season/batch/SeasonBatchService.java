package gravit.code.domain.season.batch;

import gravit.code.domain.league.domain.League;
import gravit.code.domain.league.infrastructure.LeagueRepository;
import gravit.code.domain.season.calendar.SeasonCalendar;
import gravit.code.domain.season.domain.Season;
import gravit.code.domain.season.infrastructure.SeasonRepository;
import gravit.code.domain.userLeague.domain.UserLeagueRepository;
import gravit.code.domain.userLeagueHistory.infrastructure.UserLeagueHistoryRepository;
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

    @Retryable(
            retryFor = {TransientDataAccessException.class, RecoverableDataAccessException.class, SQLException.class},
            backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    @Transactional
    public void finalizeAndRolloverWeekly(){
        // 닫을 시즌 확정 , 락
        LocalDateTime nowKst = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        Season currentSeason = seasonRepository.findCloseableActiveForUpdate(nowKst).orElseThrow(()-> new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND));
        currentSeason.finalizing();

        // 히스토리, UserLeague 스냅샷
        historyRepository.deleteBySeasonId(currentSeason); // 멱등성 보장
        int snap = historyRepository.insertFromCurrent(currentSeason);
        log.info("history snapshot rows = {}", snap);

        // 다음 시즌 확보
        LocalDateTime nextStartsAt = currentSeason.getEndsAt();
        LocalDateTime nextEndsAt = nextStartsAt.plusWeeks(1);
        Season nextSeason = seasonRepository.findPrepStartingAtForUpdate(nextStartsAt).orElseGet(()->
                seasonRepository.save(Season.prep(SeasonCalendar.isoWeekKey(nextStartsAt.toLocalDate()), nextStartsAt, nextEndsAt))
        );

        // UserLeague 초기화 및 시즌 변경
        League league = leagueRepository.findFirstByOrderBySortOrderAsc().orElseThrow(()-> new RestApiException(CustomErrorCode.LEAGUE_NOT_FOUND));
        int inits = userLeagueRepository.resetAllForNextSeason(currentSeason, nextSeason, league);
        log.info("user league rollover rows = {}", inits);

        nextSeason.activate();
        currentSeason.close();
    }
}
