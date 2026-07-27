package gravit.code.learning.listener;

import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.learning.service.LearningCommandService;
import gravit.code.mission.service.MissionService;
import gravit.code.support.TCSpringBootTest;
import gravit.code.userLeague.service.UserLeagueService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.after;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class LearningEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private LearningRepository learningRepository;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    @MockitoSpyBean
    private LearningCommandService learningCommandService;

    // 동일 OnboardingCompletedEvent를 AFTER_COMMIT으로 구독하는 다른 리스너의 실제 의존성 실행을 격리한다.
    @MockitoBean
    private MissionService missionService;

    @MockitoBean
    private UserLeagueService userLeagueService;

    @Nested
    @DisplayName("온보딩 완료 이벤트를 수신할 때")
    class CreateLearning {

        @Test
        @Transactional
        void 학습_정보를_별도_트랜잭션에서_실제로_커밋하고_큐에_적재하지_않는다() {
            // given
            long userId = 1L;

            // when
            publisher.publishEvent(new OnboardingCompletedEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(learningCommandService, timeout(2000)).createLearning(userId);
            assertThat(learningRepository.findByUserId(userId)).isPresent();
            verify(retryEventPublisher, never()).publish(eq("learning-create-retry"), any());
        }

        @Test
        @Transactional
        void 이미_학습_정보가_존재하면_재시도_큐에_적재하지_않는다() {
            // given
            long userId = 1L;
            learningRepository.save(Learning.create(userId));

            // when
            publisher.publishEvent(new OnboardingCompletedEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, after(500).never()).publish(eq("learning-create-retry"), any());
        }

        @Test
        @Transactional
        void 일시적_오류가_발생하면_재시도_큐에_적재된다() {
            // given
            long userId = 1L;
            doThrow(new RuntimeException("DB 커넥션 실패")).when(learningCommandService).createLearning(userId);

            // when
            publisher.publishEvent(new OnboardingCompletedEvent(userId));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("learning-create-retry", Map.of(
                    "userId", String.valueOf(userId)
            ));
        }
    }
}
