package gravit.code.userLeague.listener;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.infrastructure.LeagueRankSyncRetryTarget;
import gravit.code.userLeague.service.LeagueRankSyncService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankSyncListener {

    private final LeagueRankSyncService leagueRankSyncService;

    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLeagueRankChanged(LeagueRankChangedEvent event) {
        try {
            leagueRankSyncService.apply(event);
        } catch (Exception e) {
            queueRankSyncRetry(event, e);
        }
    }

    private void queueRankSyncRetry(
            LeagueRankChangedEvent event,
            Exception cause
    ) {
        log.error("랭킹 반영 실패, 재시도 큐 적재: userId={}, seasonId={}", event.userId(), event.seasonId(), cause);

        try {
            retryEventPublisher.publish(LeagueRankSyncRetryTarget.QUEUE_KEY, Map.of(
                    LeagueRankSyncRetryTarget.FIELD_SEASON_ID, String.valueOf(event.seasonId()),
                    LeagueRankSyncRetryTarget.FIELD_USER_ID, String.valueOf(event.userId())
            ));
        } catch (Exception e) {
            log.error("랭킹 반영 재시도 적재 실패, 정기 대조로 복구 대상: userId={}, seasonId={}", event.userId(), event.seasonId(), e);
        }
    }
}
