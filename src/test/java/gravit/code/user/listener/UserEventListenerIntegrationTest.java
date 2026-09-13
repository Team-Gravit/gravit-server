package gravit.code.user.listener;

import gravit.code.global.event.InterviewCompletedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserService;
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
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class UserEventListenerIntegrationTest {

    private static final long SESSION_ID = 1L;
    private static final long NON_EXISTENT_USER_ID = 999L;
    private static final int REWARD_POINTS = 30;
    private static final String XP_RETRY_QUEUE_KEY = "user-xp-interview-retry";

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    @MockitoSpyBean
    private UserService userService;

    @Nested
    @DisplayName("면접 완료 이벤트를 수신할 때")
    class HandleInterviewCompleted {

        @Test
        @Transactional
        void XP가_지급량만큼_누적된다() {
            // given
            User user = userFixture.일반_유저(1);
            InterviewCompletedEvent event = InterviewCompletedEvent.of(user.getId(), SESSION_ID, REWARD_POINTS);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            User updated = userRepository.findById(user.getId()).orElseThrow();
            assertThat(updated.getLevel().getXp()).isEqualTo(REWARD_POINTS);
        }

        @Test
        @Transactional
        void 유저가_없으면_재시도_큐에_적재하지_않는다() {
            // given
            InterviewCompletedEvent event = InterviewCompletedEvent.of(NON_EXISTENT_USER_ID, SESSION_ID, REWARD_POINTS);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, after(500).never()).publish(eq(XP_RETRY_QUEUE_KEY), any());
        }

        @Test
        @Transactional
        void 일시적_오류가_발생하면_재시도_큐에_적재된다() {
            // given
            User user = userFixture.일반_유저(1);
            doThrow(new RuntimeException("DB 커넥션 실패")).when(userService).addXp(user.getId(), REWARD_POINTS);
            InterviewCompletedEvent event = InterviewCompletedEvent.of(user.getId(), SESSION_ID, REWARD_POINTS);

            // when
            publisher.publishEvent(event);
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish(XP_RETRY_QUEUE_KEY, Map.of(
                    "userId", String.valueOf(user.getId()),
                    "xp", String.valueOf(REWARD_POINTS)
            ));
        }
    }
}
