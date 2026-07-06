package gravit.code.notification.listener;

import gravit.code.global.event.FollowedEvent;
import gravit.code.global.event.InquiryAnsweredEvent;
import gravit.code.global.event.NoticeCreatedEvent;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Log4j2
@Component
@RequiredArgsConstructor
public class NotificationEventListener {

    private final NotificationService notificationService;
    private final NotificationMessageProvider messageProvider;
    private final NotificationFacade notificationFacade;
    private final UserService userService;

    // 3.12 공지: 헤드라인 고정 + 공지 제목은 서브텍스트. 인앱 only(푸시 미발송)
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleNoticeCreated(NoticeCreatedEvent event) {
        try {
            notificationService.notifyAllUsers(
                    NotificationType.NOTICE,
                    messageProvider.noticeHeadline(),
                    event.title(),
                    event.noticeId()
            );
        } catch (Exception e) {
            log.error("공지 알림 적재 실패 - noticeId: {}", event.noticeId(), e);
        }
    }

    // 3.9 팔로우: 인앱 알림함에만 적재(푸시 미발송)
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleFollowed(FollowedEvent event) {
        try {
            String followerNickname = userService.getUser(event.followerId()).getNickname();
            String message = messageProvider.followReceived(followerNickname);
            notificationFacade.notifyUserInApp(event.followeeId(), NotificationType.FOLLOW, message, event.followerId());
        } catch (Exception e) {
            log.error("팔로우 알림 발송 실패 - followerId: {}, followeeId: {}", event.followerId(), event.followeeId(), e);
        }
    }

    // 문의 답변(명세 외, 현행 유지): 인앱 저장 + 푸시
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleInquiryAnswered(InquiryAnsweredEvent event) {
        try {
            String message = messageProvider.inquiryAnswered(event.title());
            notificationFacade.notifyUser(event.userId(), NotificationType.INQUIRY_ANSWERED, message, event.inquiryId());
        } catch (Exception e) {
            log.error("문의 답변 알림 발송 실패 - inquiryId: {}", event.inquiryId(), e);
        }
    }
}
