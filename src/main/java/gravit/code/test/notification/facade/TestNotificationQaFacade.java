package gravit.code.test.notification.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.internal.SeasonEndingMilestone;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.notification.support.NotificationPushSender;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;

import java.util.List;

// ==================== [QA 전용] 발송 조건과 무관하게 본인에게 알림을 즉시 생성하는 치트 Facade ====================
// 실제 발송과 동일하게 인앱 알림함에 적재하고, 해당 타입이 푸시를 쓰는 경우 FCM 푸시도 함께 발송한다.
@Facade
@RequiredArgsConstructor
public class TestNotificationQaFacade {

    private final NotificationService notificationService;
    private final NotificationMessageProvider messageProvider;
    private final NotificationPushSender notificationPushSender;
    private final UserService userService;

    // 지정 유저에게 알림함 적재(+ push=true면 FCM 푸시). 프로덕션 발송 채널을 단일 유저 기준으로 재현한다.
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
        List<SeasonEndingMilestone> milestones = messageProvider.seasonEndingMilestones();
        SeasonEndingMilestone milestone = milestones.stream()
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
