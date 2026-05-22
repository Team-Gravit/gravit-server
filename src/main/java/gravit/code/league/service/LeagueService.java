package gravit.code.league.service;

import gravit.code.global.exception.domain.CustomErrorCode;
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
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class LeagueService {

    private final LeagueRepository leagueRepository;
    private final SeasonRepository seasonRepository;
    private final SeasonClosedCache seasonClosedCache;
    private final SeasonPopupSeenStore seasonPopupSeenStore;
    private final UserLeagueHistoryRepository userLeagueHistoryRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final UserRepository userRepository;
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
        Season actvieSeason = seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND));

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

        // 위 2가지 조건을 다 통과하면 db 접근해서 유저의 이전/현재 리그 정보를 가져온다.
        Optional<LastSeasonPopupDto> popup = userLeagueHistoryRepository.findByUserIdAndSeasonId(userId, lastClosedSeasonId)
                .flatMap(history -> userLeagueRepository.findByUserIdAndSeasonId(userId, activeSeason.getId())
                        .map(nextUl -> LastSeasonPopupDto.from(history, nextUl)));

        // DTO 생성이 성공한 경우에만 seen 플래그를 소비한다 (먼저 마킹하면 DTO 생성 실패 시 플래그가 낭비됨)
        if (popup.isEmpty()) return Optional.empty();
        Duration ttl = ttlUntil(activeSeason.getEndsAt());
        boolean firstSeen = seasonPopupSeenStore.markSeenIfFirst(userId, lastClosedSeasonId, ttl);
        if (!firstSeen) return Optional.empty();

        return popup;
    }

    private Duration ttlUntil(LocalDateTime activeSeasonEndedAt) {
        if(activeSeasonEndedAt == null) return Duration.ofDays(10);
        Instant now = Instant.now(clock);
        Instant expiredAt = activeSeasonEndedAt.atZone(clock.getZone()).plus(TTL_BUFFER).toInstant();
        Duration ttl = Duration.between(now, expiredAt);
        return ttl.isNegative() ? DEFAULT_TTL : ttl;
    }
}
