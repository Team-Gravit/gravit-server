package gravit.code.notification.listener;

import gravit.code.friend.dto.event.FollowedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.inquiry.dto.event.InquiryAnsweredEvent;
import gravit.code.notice.dto.event.NoticeCreatedEvent;
import gravit.code.notification.infrastructure.FollowedRetryTarget;
import gravit.code.notification.infrastructure.InquiryAnsweredRetryTarget;
import gravit.code.notification.infrastructure.NoticeCreatedRetryTarget;
import gravit.code.notification.support.NotificationMessageProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.Map;

@Log4j2
@Component
@RequiredArgsConstructor
public class NotificationEventListener {

    private final NotificationMessageProvider messageProvider;
    private final RetryEventPublisher retryEventPublisher;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleNoticeCreated(NoticeCreatedEvent event) {
        try {
            retryEventPublisher.publish(NoticeCreatedRetryTarget.QUEUE_KEY, Map.of(
                    NoticeCreatedRetryTarget.FIELD_HEADLINE, messageProvider.noticeHeadline(),
                    NoticeCreatedRetryTarget.FIELD_TITLE, event.title(),
                    NoticeCreatedRetryTarget.FIELD_NOTICE_ID, String.valueOf(event.noticeId())
            ));
        } catch (Exception e) {
            log.error("공지 알림 큐 적재 실패 - noticeId: {}", event.noticeId(), e);
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleFollowed(FollowedEvent event) {
        try {
            retryEventPublisher.publish(FollowedRetryTarget.QUEUE_KEY, Map.of(
                    FollowedRetryTarget.FIELD_FOLLOWER_ID, String.valueOf(event.followerId()),
                    FollowedRetryTarget.FIELD_FOLLOWEE_ID, String.valueOf(event.followeeId())
            ));
        } catch (Exception e) {
            log.error("팔로우 알림 큐 적재 실패 - followerId: {}, followeeId: {}", event.followerId(), event.followeeId(), e);
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleInquiryAnswered(InquiryAnsweredEvent event) {
        try {
            retryEventPublisher.publish(InquiryAnsweredRetryTarget.QUEUE_KEY, Map.of(
                    InquiryAnsweredRetryTarget.FIELD_USER_ID, String.valueOf(event.userId()),
                    InquiryAnsweredRetryTarget.FIELD_TITLE, event.title(),
                    InquiryAnsweredRetryTarget.FIELD_INQUIRY_ID, String.valueOf(event.inquiryId())
            ));
        } catch (Exception e) {
            log.error("문의 답변 알림 큐 적재 실패 - inquiryId: {}", event.inquiryId(), e);
        }
    }
}
