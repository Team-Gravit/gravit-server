package gravit.code.userLeague.service;

import gravit.code.league.repository.LeagueRepository;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.userLeague.dto.internal.LeagueRankReconcileResultDto;
import gravit.code.userLeague.dto.internal.LeagueRankStateDto;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class LeagueRankingReconcileService {

    private static final int CHUNK_SIZE = 1_000;
    private static final long NO_PREVIOUS_ID = 0L;

    private final LeagueRankSyncService leagueRankSyncService;

    private final UserLeagueRepository userLeagueRepository;
    private final SeasonRepository seasonRepository;
    private final LeagueRepository leagueRepository;

    private final LeagueRankingStore leagueRankingStore;

    private final Clock clock;

    public LeagueRankReconcileResultDto reconcileActiveSeason() {
        return seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .map(season -> reconcile(season.getId()))
                .orElseGet(LeagueRankReconcileResultDto::empty);
    }

    public LeagueRankReconcileResultDto reconcile(long seasonId) {
        long startedAt = clock.millis();
        Map<Long, Long> leagueIdToExpectedCount = new HashMap<>();
        long scanned = 0;
        long placed = 0;
        long lastUserLeagueId = NO_PREVIOUS_ID;

        while (true) {
            List<LeagueRankStateDto> states = userLeagueRepository.findRankStatesAfterId(
                    seasonId,
                    lastUserLeagueId,
                    PageRequest.of(0, CHUNK_SIZE)
            );

            if (states.isEmpty()) {
                break;
            }

            for (Map.Entry<Long, List<LeagueRankStateDto>> league : groupByLeague(states).entrySet()) {
                long leagueId = league.getKey();
                List<LeagueRankStateDto> leagueStates = league.getValue();
                Map<Long, Integer> userIdToRankedPoint = leagueRankingStore.findLeaguePoints(
                        seasonId,
                        leagueId,
                        leagueStates.stream().map(LeagueRankStateDto::userId).toList()
                );

                for (LeagueRankStateDto state : leagueStates) {
                    Integer rankedPoint = userIdToRankedPoint.get(state.userId());

                    leagueIdToExpectedCount.merge(leagueId, 1L, Long::sum);

                    if (rankedPoint == null || rankedPoint != state.leaguePoint()) {
                        leagueRankSyncService.syncFromDatabase(seasonId, state.userId());
                        placed++;
                    }
                }
            }

            scanned += states.size();
            lastUserLeagueId = states.get(states.size() - 1).userLeagueId();
        }

        long rebuiltLeagues = rebuildMiscountedLeagues(seasonId, leagueIdToExpectedCount);

        LeagueRankReconcileResultDto result = new LeagueRankReconcileResultDto(
                scanned,
                placed,
                rebuiltLeagues,
                clock.millis() - startedAt
        );

        logResult(seasonId, result);

        return result;
    }

    private Map<Long, List<LeagueRankStateDto>> groupByLeague(List<LeagueRankStateDto> states) {
        Map<Long, List<LeagueRankStateDto>> leagueIdToStates = new LinkedHashMap<>();

        for (LeagueRankStateDto state : states) {
            leagueIdToStates.computeIfAbsent(state.leagueId(), leagueId -> new ArrayList<>())
                    .add(state);
        }

        return leagueIdToStates;
    }

    private long rebuildMiscountedLeagues(
            long seasonId,
            Map<Long, Long> leagueIdToExpectedCount
    ) {
        long rebuilt = 0;

        for (long leagueId : leagueRepository.findAllIds()) {
            long expected = leagueIdToExpectedCount.getOrDefault(leagueId, 0L);
            long ranked = leagueRankingStore.countRanked(seasonId, leagueId);

            if (ranked != expected) {
                leagueRankingStore.replaceLeague(
                        seasonId,
                        leagueId,
                        userLeagueRepository.findRankEntriesBySeasonIdAndLeagueId(seasonId, leagueId)
                );
                log.warn("랭킹 리그 인원이 어긋나 리그 재구축: seasonId={}, leagueId={}, 저장소={}, DB={}", seasonId, leagueId, ranked, expected);
                rebuilt++;
            }
        }

        return rebuilt;
    }

    private void logResult(
            long seasonId,
            LeagueRankReconcileResultDto result
    ) {
        if (result.hasMismatch()) {
            log.warn("랭킹 정기 대조에서 어긋남을 고침: seasonId={}, 확인={}, 반영={}, 리그 재구축={}, 소요ms={}",
                    seasonId, result.scanned(), result.placed(), result.rebuiltLeagues(), result.elapsedMs());

            return;
        }

        log.info("랭킹 정기 대조 완료, 어긋남 없음: seasonId={}, 확인={}, 소요ms={}", seasonId, result.scanned(), result.elapsedMs());
    }
}
