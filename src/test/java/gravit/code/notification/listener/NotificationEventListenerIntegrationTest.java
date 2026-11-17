package gravit.code.notification.listener;

import gravit.code.friend.dto.event.FollowedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.inquiry.dto.event.InquiryAnsweredEvent;
import gravit.code.notice.dto.event.NoticeCreatedEvent;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.repository.NotificationRepository;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.willThrow;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class NotificationEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private NotificationMessageProvider messageProvider;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UserFixture userFixture;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    @Nested
    @DisplayName("공지 생성 이벤트를 처리할 때")
    class HandleNoticeCreated {

        @Test
        @Transactional
        @DisplayName("헤드라인은 고정, 공지 제목은 서브텍스트로 재시도 큐에 적재한다")
        void 헤드라인_고정_제목_서브텍스트로_큐에_적재한다() {
            // when
            publisher.publishEvent(new NoticeCreatedEvent(10L, "정기 점검 안내"));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("notice-created-retry", Map.of(
                    "headline", messageProvider.noticeHeadline(),
                    "title", "정기 점검 안내",
                    "noticeId", "10"
            ));
        }
    }

    @Nested
    @DisplayName("팔로우 이벤트를 처리할 때")
    class HandleFollowed {

        @Test
        @Transactional
        @DisplayName("팔로우 재시도 큐에 적재한다")
        void 팔로우_재시도_큐에_적재한다() {
            // when
            publisher.publishEvent(new FollowedEvent(2L, 1L));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("followed-retry", Map.of(
                    "followerId", "2",
                    "followeeId", "1"
            ));
        }

        @Test
        @Transactional
        @DisplayName("재시도 큐 적재가 실패해도 팔로우 알림이 저장된다")
        void 큐_적재가_실패해도_팔로우_알림이_저장된다() {
            // given
            User follower = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            willThrow(new RedisConnectionFailureException("재시도 큐 연결 실패"))
                    .given(retryEventPublisher).publish(anyString(), anyMap());

            // when
            publisher.publishEvent(new FollowedEvent(follower.getId(), followee.getId()));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            assertThat(notificationRepository.findAll())
                    .anyMatch(n -> n.getUserId() == followee.getId()
                            && n.getType() == NotificationType.FOLLOW
                            && follower.getId().equals(n.getTargetId()));
        }
    }

    @Nested
    @DisplayName("문의 답변 이벤트를 처리할 때")
    class HandleInquiryAnswered {

        @Test
        @Transactional
        @DisplayName("문의 답변 재시도 큐에 적재한다")
        void 문의_답변_재시도_큐에_적재한다() {
            // when
            publisher.publishEvent(new InquiryAnsweredEvent(100L, 1L, "환불 문의"));
            TestTransaction.flagForCommit();
            TestTransaction.end();

            // then
            verify(retryEventPublisher, timeout(3000)).publish("inquiry-answered-retry", Map.of(
                    "userId", "1",
                    "title", "환불 문의",
                    "inquiryId", "100"
            ));
        }
    }
}
