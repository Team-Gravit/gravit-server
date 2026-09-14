package gravit.code.social.listener;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.lesson.dto.event.LessonCompletedEvent;
import gravit.code.social.infrastructure.SocialFeedLevelUpRetryTarget;
import gravit.code.social.infrastructure.SocialFeedStreakRetryTarget;
import gravit.code.social.infrastructure.SocialFeedTierPromotionRetryTarget;
import gravit.code.user.dto.event.LevelUpFeedEvent;
import gravit.code.userLeague.dto.event.TierPromotionFeedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;
import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
public class SocialFeedEventListener {

    private static final Set<Integer> STREAK_MILESTONES = Set.of(7, 30, 60, 100, 200, 300, 365);
    private static final int LAST_FIXED_STREAK_MILESTONE = 365;
    private static final int STREAK_MILESTONE_INTERVAL = 100;

    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLessonCompleted(LessonCompletedEvent event) {
        try {
            int days = event.afterConsecutiveSolved();
            if (isStreakMilestone(days)) {
                retryEventPublisher.publish(SocialFeedStreakRetryTarget.QUEUE_KEY, Map.of(
                        SocialFeedStreakRetryTarget.FIELD_USER_ID, String.valueOf(event.userId()),
                        SocialFeedStreakRetryTarget.FIELD_DAYS, String.valueOf(days)
                ));
            }
        } catch (Exception e) {
            log.error("소셜 피드 연속 학습 큐 적재 실패 userId={}", event.userId(), e);
        }
    }

    private boolean isStreakMilestone(int days) {
        if (STREAK_MILESTONES.contains(days)) {
            return true;
        }
        return days > LAST_FIXED_STREAK_MILESTONE && days % STREAK_MILESTONE_INTERVAL == 0;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLevelUp(LevelUpFeedEvent event) {
        try {
            retryEventPublisher.publish(SocialFeedLevelUpRetryTarget.QUEUE_KEY, Map.of(
                    SocialFeedLevelUpRetryTarget.FIELD_USER_ID, String.valueOf(event.userId()),
                    SocialFeedLevelUpRetryTarget.FIELD_NEW_LEVEL, String.valueOf(event.newLevel())
            ));
        } catch (Exception e) {
            log.error("소셜 피드 레벨업 큐 적재 실패 userId={}", event.userId(), e);
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleTierPromotion(TierPromotionFeedEvent event) {
        try {
            retryEventPublisher.publish(SocialFeedTierPromotionRetryTarget.QUEUE_KEY, Map.of(
                    SocialFeedTierPromotionRetryTarget.FIELD_USER_ID, String.valueOf(event.userId()),
                    SocialFeedTierPromotionRetryTarget.FIELD_TIER_NAME, event.tierName()
            ));
        } catch (Exception e) {
            log.error("소셜 피드 티어 승급 큐 적재 실패 userId={}", event.userId(), e);
        }
    }
}
