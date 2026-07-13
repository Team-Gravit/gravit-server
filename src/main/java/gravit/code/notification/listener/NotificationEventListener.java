package gravit.code.notification.listener;

import gravit.code.global.event.FollowedEvent;
import gravit.code.global.event.InquiryAnsweredEvent;
import gravit.code.global.event.NoticeCreatedEvent;
import gravit.code.global.event.retry.RetryEventPublisher;
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

    // 3.12 공지: 헤드라인 고정 + 공지 제목은 서브텍스트. 인앱 only(푸시 미발송)
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleNoticeCreated(NoticeCreatedEvent event) {
        try {
            retryEventPublisher.publish("notice-created-retry", Map.of(
                    "headline", messageProvider.noticeHeadline(),
                    "title", event.title(),
                    "noticeId", String.valueOf(event.noticeId())
            ));
        } catch (Exception e) {
            log.error("공지 알림 큐 적재 실패 - noticeId: {}", event.noticeId(), e);
        }
    }

    // 3.9 팔로우: 인앱 알림함에만 적재(푸시 미발송)
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleFollowed(FollowedEvent event) {
        try {
            retryEventPublisher.publish("followed-retry", Map.of(
                    "followerId", String.valueOf(event.followerId()),
                    "followeeId", String.valueOf(event.followeeId())
            ));
        } catch (Exception e) {
            log.error("팔로우 알림 큐 적재 실패 - followerId: {}, followeeId: {}", event.followerId(), event.followeeId(), e);
        }
    }

    // 문의 답변(명세 외, 현행 유지): 인앱 저장 + 푸시
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleInquiryAnswered(InquiryAnsweredEvent event) {
        try {
            retryEventPublisher.publish("inquiry-answered-retry", Map.of(
                    "userId", String.valueOf(event.userId()),
                    "title", event.title(),
                    "inquiryId", String.valueOf(event.inquiryId())
            ));
        } catch (Exception e) {
            log.error("문의 답변 알림 큐 적재 실패 - inquiryId: {}", event.inquiryId(), e);
        }
    }
}
