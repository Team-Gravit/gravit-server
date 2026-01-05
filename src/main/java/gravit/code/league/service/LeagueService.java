package gravit.code.league.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.dto.CurrentSeasonDto;
import gravit.code.league.dto.LastSeasonPopupDto;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.dto.response.LeagueResponse;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.season.service.port.SeasonClosedCache;
import gravit.code.season.service.port.SeasonPopupSeenStore;
import gravit.code.userLeagueHistory.repository.UserLeagueHistoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class LeagueService {

    private final LeagueRepository leagueRepository;
    private final SeasonRepository seasonRepository;
    private final SeasonClosedCache seasonClosedCache;
    private final SeasonPopupSeenStore seasonPopupSeenStore;
    private final UserLeagueHistoryRepository userLeagueHistoryRepository;
    private final Clock clock;

    private static final Duration TTL_BUFFER = Duration.ofHours(2);
    private static final Duration DEFAULT_TTL = Duration.ofDays(10);

    @Transactional(readOnly = true)
    public LeagueResponse getLeague(long leagueId) {
        League league = leagueRepository.findById(leagueId).orElseThrow(() -> new RestApiException(CustomErrorCode.LEAGUE_NOT_FOUND));
        return LeagueResponse.from(league);
    }

    @Transactional
    public LeagueHomeResponse enterLeagueHome(long userId){
        Season actvieSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE).orElseThrow(
                ()-> new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND));

        CurrentSeasonDto current = new CurrentSeasonDto("시즌 " + actvieSeason.getSeasonKey());

        return computeLastSeasonPopup(userId, actvieSeason)
                .map(popup -> LeagueHomeResponse.withPopup(current, popup))
                .orElseGet(() -> LeagueHomeResponse.normal(current));
    }

    private Optional<LastSeasonPopupDto> computeLastSeasonPopup(
            long userId,
            Season activeSeason
    ){
        // 이전 시즌이 없다면 그냥 리턴
        Long lastClosedSeasonId = seasonClosedCache.getLastClosedSeasonId().orElse(null);
        if (lastClosedSeasonId == null) return Optional.empty();

        // 해당하는 유저가 과거 시즌이 존재하지 않는다면 그냥 리턴
        boolean hasUserLeagueHistory = userLeagueHistoryRepository.existsByUserIdAndSeasonId(userId, lastClosedSeasonId);
        if (!hasUserLeagueHistory) return Optional.empty();

        // 캐시에 이미 팝업 확인 키-값 이 존재한다면(이미 확인한것) 그냥 리턴
        Duration ttl = ttlUntil(activeSeason.getEndsAt());
        boolean firstSeen = seasonPopupSeenStore.markSeenIfFirst(userId, lastClosedSeasonId, ttl);
        if (!firstSeen) return Optional.empty();

        // 위 3가지 조건을 다 통과하면 db 접근해서 유저의 이전 리그 정보를 가져온다.
        return userLeagueHistoryRepository.findByUserIdAndSeasonId(userId, lastClosedSeasonId)
                .map(LastSeasonPopupDto::from);
    }

    private Duration ttlUntil(LocalDateTime activeSeasonEndedAt) {
        if(activeSeasonEndedAt == null) return Duration.ofDays(10);
        Instant now = Instant.now(clock);
        Instant expiredAt = activeSeasonEndedAt.atZone(clock.getZone()).plus(TTL_BUFFER).toInstant();
        Duration ttl = Duration.between(now, expiredAt);
        return ttl.isNegative() ? DEFAULT_TTL : ttl;
    }
}
