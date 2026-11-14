package gravit.code.userLeague.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.lesson.policy.LessonRewardPolicy;
import gravit.code.userLeague.domain.LeaguePointSource;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.dto.event.TierPromotionFeedEvent;
import gravit.code.userLeague.repository.LeaguePointGrantRepository;
import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;

import static gravit.code.global.exception.domain.CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_LEAGUE_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLeaguePointService {

    private final UserLeagueRepository userLeagueRepository;
    private final LeagueRepository leagueRepository;
    private final LeaguePointGrantRepository leaguePointGrantRepository;

    private final LessonRewardPolicy lessonRewardPolicy;

    private final Clock clock;
    private final ApplicationEventPublisher publisher;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePointsForLesson(
            long userId,
            long lessonId,
            int points,
            int accuracy
    ) {
        int earnedPoints = lessonRewardPolicy.calculate(points, accuracy);

        grantOnce(userId, LeaguePointSource.LESSON, lessonId, earnedPoints);
    }

    private void grantOnce(
            long userId,
            LeaguePointSource source,
            long sourceId,
            int earnedPoints
    ) {
        int inserted = leaguePointGrantRepository.insertIfAbsent(
                userId,
                source.name(),
                sourceId,
                earnedPoints,
                LocalDateTime.now(clock)
        );

        if (inserted == 0) {
            log.info("이미 지급된 리그 포인트, 건너뜀: userId={}, source={}, sourceId={}", userId, source, sourceId);
            return;
        }

        applyLeaguePoints(userId, earnedPoints);
    }

    private void applyLeaguePoints(
            long userId,
            int earnedPoints
    ) {
        UserLeague userLeague = userLeagueRepository.findByUserId(userId).orElseThrow(() -> new RestApiException(USER_LEAGUE_NOT_FOUND));

        League oldLeague = userLeague.getLeague();
        int updatedLp = userLeague.addLeaguePoints(earnedPoints);
        League newLeague = leagueRepository.findByLpBetween(updatedLp).orElseThrow(() -> new RestApiException(LEAGUE_NOT_MATCH_LEAGUE_POINT));

        boolean isPromotion = !newLeague.getId().equals(oldLeague.getId())
                && newLeague.getSortOrder() > oldLeague.getSortOrder();

        long oldLeagueId = oldLeague.getId();
        userLeague.updateLeagueIfDifferent(newLeague);

        publisher.publishEvent(LeagueRankChangedEvent.pointsChanged(
                userId,
                userLeague.getSeason().getId(),
                oldLeagueId,
                newLeague.getId(),
                updatedLp
        ));

        if (isPromotion) {
            publisher.publishEvent(new TierPromotionFeedEvent(userId, newLeague.getName()));
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePointsForInterview(
            long userId,
            long sessionId,
            int earnedPoints
    ) {
        grantOnce(userId, LeaguePointSource.INTERVIEW, sessionId, earnedPoints);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePointsForCongratulation(
            long userId,
            int earnedPoints
    ) {
        applyLeaguePoints(userId, earnedPoints);
    }
}
