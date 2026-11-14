package gravit.code.userLeague.scheduler;

import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.userLeague.service.LeagueRankingRebuildService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankingLossDetectScheduler {

    private final LeagueRankingRebuildService leagueRankingRebuildService;

    private final SeasonRepository seasonRepository;

    @Scheduled(
            cron = "${scheduler.league-ranking.loss-detect-cron:*/30 * * * * *}",
            scheduler = "retrySweepScheduler"
    )
    public void detectLoss() {
        seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .ifPresent(season -> rebuildIfLost(season.getId()));
    }

    private void rebuildIfLost(long seasonId) {
        try {
            leagueRankingRebuildService.rebuildIfLost(seasonId);
        } catch (Exception e) {
            log.warn("랭킹 유실 확인 실패, 다음 주기에 다시 확인: seasonId={}", seasonId, e);
        }
    }
}
