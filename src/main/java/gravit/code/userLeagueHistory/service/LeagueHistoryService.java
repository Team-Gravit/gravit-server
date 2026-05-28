package gravit.code.userLeagueHistory.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.dto.response.LeagueHistoryResponse;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Slf4j
@RequiredArgsConstructor
@Service
public class LeagueHistoryService {

    private final SeasonRepository seasonRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final UserLeagueHistoryRepository userLeagueHistoryRepository;

    @Transactional(readOnly = true)
    public LeagueHistoryResponse getMyLeagueHistory(long userId) {
        return buildLeagueHistory(userId);
    }

    @Transactional(readOnly = true)
    public LeagueHistoryResponse getUserLeagueHistory(long userId) {
        return buildLeagueHistory(userId);
    }

    private LeagueHistoryResponse buildLeagueHistory(long userId) {
        Season activeSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND));

        Optional<UserLeague> currentUserLeague = userLeagueRepository.findByUserIdAndSeasonId(userId, activeSeason.getId());
        int currentRank = userLeagueRepository.findCurrentRankByUserId(userId, activeSeason.getId()).orElse(0);
        List<UserLeagueHistory> histories = userLeagueHistoryRepository.findAllByUserIdOrderBySeason(userId);

        int totalSeasonCount = histories.size() + (currentUserLeague.isPresent() ? 1 : 0);
        int top3SeasonCount = (int) histories.stream().filter(h -> h.getFinalRank() <= 3).count();
        String bestLeagueName = computeBestLeagueName(histories, currentUserLeague.orElse(null));

        List<LeagueHistoryResponse.SeasonHistoryEntry> seasonHistory = new ArrayList<>();
        for (UserLeagueHistory h : histories) {
            seasonHistory.add(new LeagueHistoryResponse.SeasonHistoryEntry(
                    h.getSeason().getSeasonKey(),
                    h.getFinalLeague().getName(),
                    h.getFinalLeague().getSortOrder(),
                    false
            ));
        }
        currentUserLeague.ifPresent(ul -> seasonHistory.add(
                new LeagueHistoryResponse.SeasonHistoryEntry(
                        activeSeason.getSeasonKey(),
                        ul.getLeague().getName(),
                        ul.getLeague().getSortOrder(),
                        true
                )
        ));

        return LeagueHistoryResponse.of(currentRank, totalSeasonCount, top3SeasonCount, bestLeagueName, seasonHistory);
    }

    private String computeBestLeagueName(
            List<UserLeagueHistory> histories,
            UserLeague currentUserLeague
    ) {
        int bestSortOrder = -1;
        String bestName = null;

        for (UserLeagueHistory h : histories) {
            int so = h.getFinalLeague().getSortOrder();
            if (so > bestSortOrder) {
                bestSortOrder = so;
                bestName = h.getFinalLeague().getName();
            }
        }

        if (currentUserLeague != null) {
            int so = currentUserLeague.getLeague().getSortOrder();
            if (so > bestSortOrder) {
                bestName = currentUserLeague.getLeague().getName();
            }
        }

        return bestName;
    }
}


