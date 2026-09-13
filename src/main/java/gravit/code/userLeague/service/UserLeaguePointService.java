package gravit.code.userLeague.service;

import gravit.code.global.event.LeagueRankChangedEvent;
import gravit.code.global.event.TierPromotionFeedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.repository.LeagueRepository;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserLeaguePointService {
    private final UserLeagueRepository userLeagueRepository;
    private final LeagueRepository leagueRepository;
    private final ApplicationEventPublisher publisher;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePointsForLesson(
            Long userId,
            int points,
            int accuracy
    ) {
        applyLeaguePoints(userId, (int) Math.round(points * accuracy * 0.01));
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePointsForInterview(
            long userId,
            int earnedPoints
    ) {
        applyLeaguePoints(userId, earnedPoints);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addLeaguePointsForCongratulation(
            long userId,
            int earnedPoints
    ) {
        applyLeaguePoints(userId, earnedPoints);
    }

    private void applyLeaguePoints(
            long userId,
            int earnedPoints
    ) {
        UserLeague userLeague = userLeagueRepository.findByUserId(userId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_LEAGUE_NOT_FOUND));

        League oldLeague = userLeague.getLeague();
        int updatedLp = userLeague.addLeaguePoints(earnedPoints);
        League newLeague = leagueRepository.findByLpBetween(updatedLp).orElseThrow(() -> new RestApiException(CustomErrorCode.LEAGUE_NOT_MATCH_LEAGUE_POINT));

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
}
