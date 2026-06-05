package gravit.code.notification.listener;

import gravit.code.global.event.NoticeCreatedEvent;
import gravit.code.global.event.SeasonRolledOverEvent;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationMessageProvider;
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

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleNoticeCreated(NoticeCreatedEvent event) {
        try {
            String message = messageProvider.noticePublished(event.title());
            notificationService.notifyAllUsers(NotificationType.NOTICE, message, event.noticeId());
        } catch (Exception e) {
            log.error("공지 알림 적재 실패 - noticeId: {}", event.noticeId(), e);
        }
    }

    // 3.8 시즌 롤오버 커밋 직후 전체 유저에게 새 시즌 시작 알림 푸시
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleSeasonRolledOver(SeasonRolledOverEvent event) {
        try {
            notificationFacade.sendSeasonResetAlerts();
        } catch (Exception e) {
            log.error("시즌 종료 알림 발송 실패 - newSeasonKey: {}", event.newSeasonKey(), e);
        }
    }
}
