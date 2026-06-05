package gravit.code.season.batch;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.calendar.SeasonCalendar;
import gravit.code.season.domain.Season;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import gravit.code.global.event.SeasonRolledOverEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.RecoverableDataAccessException;
import org.springframework.dao.TransientDataAccessException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.time.Clock;
import java.time.LocalDateTime;


@Service
@RequiredArgsConstructor
@Slf4j
public class SeasonBatchService {
    private final SeasonRepository seasonRepository;
    private final UserLeagueHistoryRepository historyRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final SeasonClosedCache seasonClosedCache;
    private final ApplicationEventPublisher publisher;
    private final Clock clock;

    @Retryable(
            retryFor = {TransientDataAccessException.class, RecoverableDataAccessException.class, SQLException.class},
            backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    @Transactional
    public void finalizeAndRollover(){
        // 닫을 시즌 확정 , 락
        LocalDateTime nowKst = LocalDateTime.now(clock);
        Season currentSeason = seasonRepository.findCloseableActiveByNowForUpdate(nowKst).orElseThrow(()-> new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND));
        currentSeason.finalizing();

        // 히스토리, UserLeague 스냅샷
        historyRepository.deleteBySeasonId(currentSeason); // 멱등성 보장
        int snap = historyRepository.insertFromCurrent(currentSeason.getId(), nowKst);

        // 다음 시즌 확보 (4개월 단위)
        LocalDateTime nextStartsAt = currentSeason.getEndsAt();
        LocalDateTime nextEndsAt = nextStartsAt.plusMonths(4);
        Season nextSeason = seasonRepository.findPrepByStartingAt(nextStartsAt).orElseGet(()->
                seasonRepository.save(Season.prep(SeasonCalendar.seasonKey(nextStartsAt.toLocalDate()), nextStartsAt, nextEndsAt))
        );

        // UserLeague 소프트 리셋: 직전 시즌 티어 기준으로 시작 티어·LP 차등 지급
        int inits = userLeagueRepository.softResetForNextSeason(currentSeason.getId(), nextSeason.getId());
        log.info("히스토리 스냅샷 로우 수: {},  유저 리그 롤오버 로우 수 = {}", snap, inits);

        nextSeason.activate();
        currentSeason.close();

        // 전 시즌 id 캐싱
        seasonClosedCache.setLastClosedSeasonId(currentSeason.getId());

        // 3.8 시즌 종료 + 새 시즌 시작 알림: 커밋 이후 AFTER_COMMIT 리스너에서 전체 발송
        publisher.publishEvent(new SeasonRolledOverEvent(nextSeason.getSeasonKey()));
    }
}
