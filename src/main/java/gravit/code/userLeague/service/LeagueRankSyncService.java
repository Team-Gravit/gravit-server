package gravit.code.userLeague.service;

import gravit.code.league.repository.LeagueRepository;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.dto.internal.LeagueRankStateDto;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class LeagueRankSyncService {

    private final UserLeagueRepository userLeagueRepository;
    private final LeagueRepository leagueRepository;

    private final LeagueRankingStore leagueRankingStore;

    private volatile List<Long> leagueIds;

    public void apply(LeagueRankChangedEvent event) {
        List<Long> seasonLeagueIds = leagueIdsIncluding(event.newLeagueId());

        if (event.removed()) {
            leagueRankingStore.evict(event.seasonId(), seasonLeagueIds, event.userId());

            return;
        }

        place(event.seasonId(), seasonLeagueIds, event.newLeagueId(), event.userId(), event.leaguePoint());
    }

    private List<Long> leagueIdsIncluding(long leagueId) {
        List<Long> cached = leagueIds;

        if (cached != null && cached.contains(leagueId)) {
            return cached;
        }

        return reloadLeagueIds();
    }

    private List<Long> reloadLeagueIds() {
        List<Long> loaded = List.copyOf(leagueRepository.findAllIds());
        leagueIds = loaded;

        return loaded;
    }

    private void place(
            long seasonId,
            List<Long> seasonLeagueIds,
            long leagueId,
            long userId,
            int leaguePoint
    ) {
        boolean placed = leagueRankingStore.place(seasonId, seasonLeagueIds, leagueId, userId, leaguePoint);

        if (!placed) {
            log.debug("더 새 리그 점수가 이미 반영돼 랭킹 반영을 건너뜀: userId={}, seasonId={}, leaguePoint={}", userId, seasonId, leaguePoint);
        }
    }

    @Transactional(readOnly = true)
    public void syncFromDatabase(
            long seasonId,
            long userId
    ) {
        Optional<LeagueRankStateDto> found = userLeagueRepository.findRankStateByUserId(userId);

        if (found.isEmpty() || found.get().seasonId() != seasonId) {
            leagueRankingStore.evict(seasonId, reloadLeagueIds(), userId);

            return;
        }

        LeagueRankStateDto state = found.get();
        place(seasonId, leagueIdsIncluding(state.leagueId()), state.leagueId(), userId, state.leaguePoint());
    }
}
