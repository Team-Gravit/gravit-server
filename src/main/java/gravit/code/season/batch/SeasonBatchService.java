package gravit.code.season.batch;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.calendar.SeasonCalendar;
import gravit.code.season.domain.Season;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.LeagueRankingRebuildService;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.RecoverableDataAccessException;
import org.springframework.dao.TransientDataAccessException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.time.Clock;
import java.time.LocalDateTime;

import static gravit.code.global.exception.domain.CustomErrorCode.ACTIVE_SEASON_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Slf4j
public class SeasonBatchService {

    private final LeagueRankingRebuildService leagueRankingRebuildService;

    private final SeasonRepository seasonRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final UserLeagueHistoryRepository historyRepository;

    private final SeasonClosedCache seasonClosedCache;
    private final LeagueRankingStore leagueRankingStore;

    private final Clock clock;

    @Retryable(
            retryFor = {TransientDataAccessException.class, RecoverableDataAccessException.class, SQLException.class},
            backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    @Transactional
    public void finalizeAndRollover(){
        LocalDateTime nowKst = LocalDateTime.now(clock);
        Season currentSeason = seasonRepository.findCloseableActiveByNowForUpdate(nowKst).orElseThrow(()-> new RestApiException(ACTIVE_SEASON_NOT_FOUND));
        currentSeason.finalizing();

        historyRepository.deleteBySeasonId(currentSeason);
        int snap = historyRepository.insertFromCurrent(currentSeason.getId(), nowKst);

        LocalDateTime nextStartsAt = currentSeason.getEndsAt();
        LocalDateTime nextEndsAt = nextStartsAt.plusMonths(SeasonCalendar.SEASON_MONTHS);
        Season nextSeason = seasonRepository.findPrepByStartingAt(nextStartsAt).orElseGet(()->
                seasonRepository.save(Season.prep(SeasonCalendar.seasonKey(nextStartsAt.toLocalDate()), nextStartsAt, nextEndsAt))
        );

        int inits = userLeagueRepository.softResetForNextSeason(currentSeason.getId(), nextSeason.getId());
        log.info("히스토리 스냅샷 로우 수: {},  유저 리그 롤오버 로우 수 = {}", snap, inits);

        leagueRankingRebuildService.rebuild(nextSeason.getId());
        leagueRankingStore.deleteSeason(currentSeason.getId());

        nextSeason.activate();
        currentSeason.close();

        seasonClosedCache.setLastClosedSeasonId(currentSeason.getId());
    }
}
