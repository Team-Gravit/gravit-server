package gravit.code.notification.listener;

import gravit.code.global.event.FollowedEvent;
import gravit.code.global.event.InquiryAnsweredEvent;
import gravit.code.global.event.NoticeCreatedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class NotificationEventListenerIntegrationTest {

    @Autowired
    private ApplicationEventPublisher publisher;

    @Autowired
    private NotificationMessageProvider messageProvider;

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
