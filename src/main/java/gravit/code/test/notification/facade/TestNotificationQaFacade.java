package gravit.code.test.notification.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.internal.SeasonEndingMilestoneDto;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.notification.support.NotificationPushSender;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class TestNotificationQaFacade {

    private final NotificationService notificationService;
    private final UserService userService;

    private final NotificationMessageProvider messageProvider;
    private final NotificationPushSender notificationPushSender;

    private void createForUser(
            long userId,
            NotificationType type,
            String message,
            String subText,
            Long targetId,
            boolean push
    ) {
        notificationService.notify(userId, type, message, subText, targetId);
        if (push) {
            notificationPushSender.pushToUser(userId, type.toPushData(targetId), message);
        }
    }

    public void sendConsecutiveLearningWarningToUser(
            long userId,
            int consecutiveDays
    ) {
        createForUser(
                userId,
                NotificationType.CONSECUTIVE_LEARNING_WARNING,
                messageProvider.consecutiveWarning(consecutiveDays),
                messageProvider.consecutiveWarningSubText(),
                null,
                true
        );
    }

    public void sendDailyIncompleteToUser(long userId) {
        createForUser(
                userId,
                NotificationType.DAILY_INCOMPLETE,
                messageProvider.randomDailyIncomplete(),
                null,
                null,
                true
        );
    }

    public void sendInactivityToUser(
            long userId,
            int inactiveDays
    ) {
        createForUser(
                userId,
                NotificationType.INACTIVITY,
                messageProvider.inactivity(inactiveDays),
                null,
                null,
                true
        );
    }

    public void sendNewContentToUser(
            long userId,
            long unitId
    ) {
        createForUser(userId, NotificationType.NEW_CONTENT, messageProvider.newContent(), null, unitId, false);
    }

    public void sendSeasonEndingToUser(
            long userId,
            int daysBefore
    ) {
        List<SeasonEndingMilestoneDto> milestones = messageProvider.seasonEndingMilestones();
        SeasonEndingMilestoneDto milestone = milestones.stream()
                .filter(m -> m.daysBefore() == daysBefore)
                .findFirst()
                .orElse(milestones.get(0));
        createForUser(userId, NotificationType.SEASON_ENDING, milestone.headline(), milestone.subText(), null, true);
    }

    public void sendSeasonResetToUser(long userId) {
        createForUser(userId, NotificationType.SEASON_RESET, messageProvider.seasonReset(), null, null, true);
    }

    public void sendFollowToUser(
            long userId,
            long followerId
    ) {
        String nickname = userService.getUser(followerId).getNickname();
        createForUser(userId, NotificationType.FOLLOW, messageProvider.followReceived(nickname), null, followerId, false);
    }

    public void sendCongratulationToUser(
            long userId,
            long congratulatorId
    ) {
        String nickname = userService.getUser(congratulatorId).getNickname();
        createForUser(userId, NotificationType.CONGRATULATION, messageProvider.congratulation(nickname), null, null, false);
    }

    public void sendNoticeToUser(
            long userId,
            String title,
            Long noticeId
    ) {
        createForUser(userId, NotificationType.NOTICE, messageProvider.noticeHeadline(), title, noticeId, false);
    }

    public void sendInquiryAnsweredToUser(
            long userId,
            String title,
            Long inquiryId
    ) {
        createForUser(userId, NotificationType.INQUIRY_ANSWERED, messageProvider.inquiryAnswered(title), null, inquiryId, true);
    }
}
