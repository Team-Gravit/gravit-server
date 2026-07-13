package gravit.code.social.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.LevelUpFeedEvent;
import gravit.code.global.event.TierPromotionFeedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
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

    private final RetryEventPublisher retryEventPublisher;

    private static final Set<Integer> STREAK_MILESTONES = Set.of(7, 30, 60, 100, 200, 300, 365);

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLessonCompleted(LessonCompletedEvent event) {
        try {
            int days = event.afterConsecutiveSolved();
            if (isStreakMilestone(days)) {
                retryEventPublisher.publish("social-feed-streak-retry", Map.of(
                        "userId", String.valueOf(event.userId()),
                        "days", String.valueOf(days)
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
        return days > 365 && days % 100 == 0;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleLevelUp(LevelUpFeedEvent event) {
        try {
            retryEventPublisher.publish("social-feed-levelup-retry", Map.of(
                    "userId", String.valueOf(event.userId()),
                    "newLevel", String.valueOf(event.newLevel())
            ));
        } catch (Exception e) {
            log.error("소셜 피드 레벨업 큐 적재 실패 userId={}", event.userId(), e);
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleTierPromotion(TierPromotionFeedEvent event) {
        try {
            retryEventPublisher.publish("social-feed-tier-retry", Map.of(
                    "userId", String.valueOf(event.userId()),
                    "tierName", event.tierName()
            ));
        } catch (Exception e) {
            log.error("소셜 피드 티어 승급 큐 적재 실패 userId={}", event.userId(), e);
        }
    }
}
