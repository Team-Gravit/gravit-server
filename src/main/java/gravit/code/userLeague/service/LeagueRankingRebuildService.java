package gravit.code.userLeague.service;

import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class LeagueRankingRebuildService {

    private static final int NOTHING_REBUILT = 0;

    private final UserLeagueRepository userLeagueRepository;

    private final LeagueRankingStore leagueRankingStore;

    @Transactional(readOnly = true)
    public int rebuild(long seasonId) {
        List<LeagueRankEntry> entries = userLeagueRepository.findRankEntriesBySeasonId(seasonId);

        leagueRankingStore.replaceAll(seasonId, entries);
        log.info("랭킹 재구축 완료: seasonId={}, 반영 인원={}", seasonId, entries.size());

        return entries.size();
    }

    @Transactional(readOnly = true)
    public int rebuildIfStale(long seasonId) {
        long ranked = leagueRankingStore.countRanked(seasonId);
        long expected = userLeagueRepository.countRankEntriesBySeasonId(seasonId);

        if (ranked == expected) {
            log.info("랭킹 인원이 일치해 재구축을 건너뜀: seasonId={}, 인원={}", seasonId, expected);

            return NOTHING_REBUILT;
        }

        log.warn("랭킹 인원이 어긋나 재구축: seasonId={}, 저장소={}, DB={}", seasonId, ranked, expected);

        return rebuild(seasonId);
    }
}
