package gravit.code.userLeague.listener;

import gravit.code.global.event.LeagueRankChangedEvent;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankSyncListener {

    private final LeagueRankingStore leagueRankingStore;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLeagueRankChanged(LeagueRankChangedEvent event) {
        try {
            apply(event);
        } catch (Exception e) {
            log.error("랭킹 반영 실패: userId={}, seasonId={}", event.userId(), event.seasonId(), e);
        }
    }

    public void apply(LeagueRankChangedEvent event) {
        if (event.removed()) {
            leagueRankingStore.remove(event.seasonId(), event.newLeagueId(), event.userId());

            return;
        }

        if (event.oldLeagueId() == null) {
            leagueRankingStore.put(event.seasonId(), event.newLeagueId(), event.userId(), event.leaguePoint());

            return;
        }

        leagueRankingStore.move(
                event.seasonId(),
                event.oldLeagueId(),
                event.newLeagueId(),
                event.userId(),
                event.leaguePoint()
        );
    }
}
