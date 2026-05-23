package gravit.code.social.listener;

import static java.util.concurrent.TimeUnit.SECONDS;
import static org.assertj.core.api.Assertions.assertThat;
import static org.awaitility.Awaitility.await;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.after;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.LevelUpFeedEvent;
import gravit.code.global.event.TierPromotionFeedEvent;
import gravit.code.mission.service.MissionService;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.facade.SocialFacade;
import gravit.code.social.repository.SocialFeedRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.service.UserLeaguePointService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

@TCSpringBootTest
class SocialFeedEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @MockitoSpyBean
    private SocialFacade socialFacade;

    @Autowired
    private SocialFeedRepository socialFeedRepository;

    // LessonCompletedEvent를 BEFORE_COMMIT으로 구독하는 리스너의 의존성 격리
    @MockitoBean
    private UserLeaguePointService userLeaguePointService;

    @MockitoBean
    private MissionService missionService;

    // LessonCompletedEvent를 AFTER_COMMIT + @Async로 구독하는 리스너 격리
    @MockitoBean
    private DailyLearningRecordService dailyLearningRecordService;

    @Nested
    @DisplayName("레슨 완료 이벤트를 처리할 때")
    class HandleLessonCompleted {

        @Test
        @Transactional
        void 마일스톤_연속_학습일이면_피드가_저장된다() {
            // given — 7일 연속 학습
            LessonCompletedEvent event = new LessonCompletedEvent(1L, 1L, 1L, 10, 80, 120, 6, 7);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(socialFacade, timeout(3000)).publishFeed(1L, FeedEventType.STREAK_DAYS, "7");
        }

        @Test
        @Transactional
        void 마일스톤이_아닌_연속_학습일이면_피드가_저장되지_않는다() {
            // given — 5일 (마일스톤 아님)
            LessonCompletedEvent event = new LessonCompletedEvent(1L, 1L, 1L, 10, 80, 120, 4, 5);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then — 500ms 대기 후 호출이 없음을 확인
            verify(socialFacade, after(500).never()).publishFeed(anyLong(), any(), any());
        }
    }

    @Nested
    @DisplayName("레벨업 이벤트를 처리할 때")
    class HandleLevelUp {

        @Test
        @Transactional
        void 레벨업_이벤트로_피드가_저장된다() {
            // given
            LevelUpFeedEvent event = new LevelUpFeedEvent(1L, 5);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(socialFacade, timeout(3000)).publishFeed(1L, FeedEventType.LEVEL_UP, "5");
        }

        @Test
        @Transactional
        void 레벨업_피드가_실제_DB에_저장된다() {
            // given
            LevelUpFeedEvent event = new LevelUpFeedEvent(1L, 5);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            await().atMost(3, SECONDS).untilAsserted(() ->
                    assertThat(socialFeedRepository.findAll())
                            .anyMatch(f -> f.getEventType() == FeedEventType.LEVEL_UP && f.getEventValue().equals("5"))
            );
        }
    }

    @Nested
    @DisplayName("티어 승급 이벤트를 처리할 때")
    class HandleTierPromotion {

        @Test
        @Transactional
        void 티어_승급_이벤트로_피드가_저장된다() {
            // given
            TierPromotionFeedEvent event = new TierPromotionFeedEvent(1L, "골드");

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(socialFacade, timeout(3000)).publishFeed(1L, FeedEventType.TIER_PROMOTION, "골드");
        }

        @Test
        @Transactional
        void 티어_승급_피드가_실제_DB에_저장된다() {
            // given
            TierPromotionFeedEvent event = new TierPromotionFeedEvent(1L, "골드");

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            await().atMost(3, SECONDS).untilAsserted(() ->
                    assertThat(socialFeedRepository.findAll())
                            .anyMatch(f -> f.getEventType() == FeedEventType.TIER_PROMOTION && f.getEventValue().equals("골드"))
            );
        }
    }
}
