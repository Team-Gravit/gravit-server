package gravit.code.userLeague.scheduler;

import gravit.code.userLeague.service.LeagueRankingReconcileService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class LeagueRankingReconcileScheduler {

    private final LeagueRankingReconcileService leagueRankingReconcileService;

    @Scheduled(
            cron = "${scheduler.league-ranking.reconcile-cron:0 30 * * * *}",
            zone = "Asia/Seoul",
            scheduler = "retrySweepScheduler"
    )
    public void reconcile() {
        leagueRankingReconcileService.reconcileActiveSeason();
    }
}
