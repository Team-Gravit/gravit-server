package gravit.code.userLeague.scheduler;

import gravit.code.userLeague.service.LeaguePointReconcileService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LeaguePointReconcileScheduler {

    private final LeaguePointReconcileService leaguePointReconcileService;

    @Scheduled(
            fixedDelay = 600_000,
            initialDelay = 600_000,
            scheduler = "retrySweepScheduler"
    )
    public void reconcile() {
        leaguePointReconcileService.reconcileLessonPoints();
    }
}
