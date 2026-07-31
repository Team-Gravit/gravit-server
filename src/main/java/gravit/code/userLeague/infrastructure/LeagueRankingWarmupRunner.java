package gravit.code.userLeague.infrastructure;

import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.userLeague.service.LeagueRankingRebuildService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class LeagueRankingWarmupRunner implements ApplicationRunner {

    private final SeasonRepository seasonRepository;
    private final LeagueRankingRebuildService leagueRankingRebuildService;

    @Override
    public void run(ApplicationArguments args) {
        Optional<Season> activeSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE);

        if (activeSeason.isEmpty()) {
            log.info("활성 시즌이 없어 랭킹 워밍업을 건너뜀");

            return;
        }

        long seasonId = activeSeason.get().getId();

        try {
            leagueRankingRebuildService.rebuildIfStale(seasonId);
        } catch (Exception e) {
            log.error("랭킹 워밍업 실패: seasonId={}", seasonId, e);
        }
    }
}
