package gravit.code.notification.batch;

import gravit.code.notification.facade.NotificationBatchFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class NotificationScheduler {

    private final NotificationBatchFacade notificationBatchFacade;

    @Scheduled(cron = "0 0 21 * * *", zone = "Asia/Seoul")
    public void sendConsecutiveLearningWarnings(){
        notificationBatchFacade.sendConsecutiveLearningWarnings();
    }

    @Scheduled(cron = "0 0 21 * * *", zone = "Asia/Seoul")
    public void sendDailyIncompleteReminders(){
        notificationBatchFacade.sendDailyIncompleteReminders();
    }

    @Scheduled(cron = "0 0 21 * * *", zone = "Asia/Seoul")
    public void sendInactivityReminders(){
        notificationBatchFacade.sendInactivityReminders();
    }

    // 매일 ACTIVE 시즌 종료까지 남은 일수를 평가해 7일/3일 전이면 발송 (endsAt 기반 가드)
    @Scheduled(cron = "0 0 21 * * *", zone = "Asia/Seoul")
    public void sendSeasonEndingReminders(){
        notificationBatchFacade.sendSeasonEndingReminders();
    }

    // 매일 오전 9시: 직전 자정에 시즌이 롤오버됐으면(=ACTIVE 시즌 시작일이 오늘) 시즌 종료+새 시즌 알림 발송.
    // 자정 즉시 발송 시 발생하는 새벽 푸시를 피하기 위해 오전 9시로 분리한다.
    @Scheduled(cron = "0 0 9 * * *", zone = "Asia/Seoul")
    public void sendSeasonResetAlerts(){
        notificationBatchFacade.sendSeasonResetAlerts();
    }
}
