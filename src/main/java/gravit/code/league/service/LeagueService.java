package gravit.code.league.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.dto.internal.CurrentSeasonDto;
import gravit.code.league.dto.internal.LastSeasonPopupDto;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.dto.response.LeagueResponse;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.season.service.port.SeasonPopupSeenStore;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.ACTIVE_SEASON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Slf4j
public class LeagueService {

    private static final Duration TTL_BUFFER = Duration.ofHours(2);
    private static final Duration DEFAULT_TTL = Duration.ofDays(10);

    private final LeagueRepository leagueRepository;
    private final SeasonRepository seasonRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final UserLeagueHistoryRepository userLeagueHistoryRepository;
    private final UserRepository userRepository;

    private final SeasonClosedCache seasonClosedCache;
    private final SeasonPopupSeenStore seasonPopupSeenStore;

    private final Clock clock;

    @Transactional(readOnly = true)
    public LeagueResponse getLeague(long leagueId) {
        League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RestApiException(LEAGUE_NOT_FOUND));
        return LeagueResponse.from(league);
    }

    @Transactional
    public LeagueHomeResponse enterLeagueHome(long userId){
        Season actvieSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .orElseThrow(()-> new RestApiException(ACTIVE_SEASON_NOT_FOUND));

        CurrentSeasonDto current = new CurrentSeasonDto("시즌 " + actvieSeason.getSeasonKey());

        return computeLastSeasonPopup(userId, actvieSeason)
                .map(popup -> LeagueHomeResponse.withPopup(current, popup))
                .orElseGet(() -> LeagueHomeResponse.normal(current));
    }

    private Optional<LastSeasonPopupDto> computeLastSeasonPopup(
            long userId,
            Season activeSeason
    ) {
        Long lastClosedSeasonId = findLastClosedSeasonId(userId).orElse(null);
        if (lastClosedSeasonId == null) return Optional.empty();

        boolean hasUserLeagueHistory = userLeagueHistoryRepository.existsByUserIdAndSeasonId(userId, lastClosedSeasonId);
        if (!hasUserLeagueHistory) return Optional.empty();

        Optional<LastSeasonPopupDto> popup = userLeagueHistoryRepository.findByUserIdAndSeasonId(userId, lastClosedSeasonId)
                .flatMap(history -> userLeagueRepository.findByUserIdAndSeasonId(userId, activeSeason.getId())
                        .map(nextUl -> LastSeasonPopupDto.from(history, nextUl)));

        if (popup.isEmpty()) return Optional.empty();
        Duration ttl = ttlUntil(activeSeason.getEndsAt());
        boolean firstSeen = markPopupSeenIfFirst(userId, lastClosedSeasonId, ttl);
        if (!firstSeen) return Optional.empty();

        return popup;
    }

    private Optional<Long> findLastClosedSeasonId(long userId) {
        try {
            return seasonClosedCache.getLastClosedSeasonId();
        } catch (DataAccessException e) {
            log.warn("시즌 팝업 Redis 조회 실패, 팝업 없이 응답: userId={}", userId, e);
            return Optional.empty();
        }
    }

    private Duration ttlUntil(LocalDateTime activeSeasonEndedAt) {
        if(activeSeasonEndedAt == null) return DEFAULT_TTL;
        Instant now = Instant.now(clock);
        Instant expiredAt = activeSeasonEndedAt.atZone(clock.getZone()).plus(TTL_BUFFER).toInstant();
        Duration ttl = Duration.between(now, expiredAt);
        return ttl.isNegative() ? DEFAULT_TTL : ttl;
    }

    private boolean markPopupSeenIfFirst(
            long userId,
            long seasonId,
            Duration ttl
    ) {
        try {
            return seasonPopupSeenStore.markSeenIfFirst(userId, seasonId, ttl);
        } catch (DataAccessException e) {
            log.warn("시즌 팝업 Redis 조회 실패, 팝업 없이 응답: userId={}", userId, e);
            return false;
        }
    }
}
