package gravit.code.social.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.LevelUpFeedEvent;
import gravit.code.global.event.TierPromotionFeedEvent;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.facade.SocialFacade;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
public class SocialFeedEventListener {

    private final SocialFacade socialFacade;

    private static final Set<Integer> STREAK_MILESTONES = Set.of(7, 30, 60, 100, 200, 300, 365);

    @Async("socialFeedAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleLessonCompleted(LessonCompletedEvent event) {
        try {
            int days = event.afterConsecutiveSolved();
            if (isStreakMilestone(days)) {
                socialFacade.publishFeed(event.userId(), FeedEventType.STREAK_DAYS, String.valueOf(days));
            }
        } catch (Exception e) {
            log.error("소셜 피드 연속 학습 저장 실패 userId={}", event.userId(), e);
        }
    }

    @Async("socialFeedAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleLevelUp(LevelUpFeedEvent event) {
        try {
            socialFacade.publishFeed(event.userId(), FeedEventType.LEVEL_UP, String.valueOf(event.newLevel()));
        } catch (Exception e) {
            log.error("소셜 피드 레벨업 저장 실패 userId={}", event.userId(), e);
        }
    }

    @Async("socialFeedAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleTierPromotion(TierPromotionFeedEvent event) {
        try {
            socialFacade.publishFeed(event.userId(), FeedEventType.TIER_PROMOTION, event.tierName());
        } catch (Exception e) {
            log.error("소셜 피드 티어 승급 저장 실패 userId={}", event.userId(), e);
        }
    }

    private boolean isStreakMilestone(int days) {
        if (STREAK_MILESTONES.contains(days)) {
            return true;
        }
        return days > 365 && days % 100 == 0;
    }
}
