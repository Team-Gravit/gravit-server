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

    @Scheduled(cron = "0 0 21 * * *", zone = "Asia/Seoul")
    public void sendSeasonEndingReminders(){
        notificationBatchFacade.sendSeasonEndingReminders();
    }

    @Scheduled(cron = "0 0 9 * * *", zone = "Asia/Seoul")
    public void sendSeasonResetAlerts(){
        notificationBatchFacade.sendSeasonResetAlerts();
    }
}
