package gravit.code.notification.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUserDto;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.internal.InactivityMilestoneDto;
import gravit.code.notification.service.NotificationService;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.notification.support.NotificationPushSender;
import gravit.code.season.service.SeasonService;
import gravit.code.user.service.UserAccessService;
import lombok.RequiredArgsConstructor;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Facade
@RequiredArgsConstructor
public class NotificationBatchFacade {

    private final NotificationService notificationService;
    private final LearningQueryService learningQueryService;
    private final UserAccessService userAccessService;
    private final SeasonService seasonService;

    private final NotificationMessageProvider messageProvider;
    private final NotificationPushSender notificationPushSender;

    private final Clock clock;

    public void sendConsecutiveLearningWarnings() {
        List<ConsecutiveAtRiskUserDto> targets = learningQueryService.getConsecutiveAtRiskUsers();

        if (targets.isEmpty()) {
            return;
        }

        Map<Long, String> userIdToMessage = targets.stream()
                .collect(Collectors.toMap(
                        ConsecutiveAtRiskUserDto::userId,
                        target -> messageProvider.consecutiveWarning(target.consecutiveSolvedDays())
                ));

        notificationService.notifyEach(
                NotificationType.CONSECUTIVE_LEARNING_WARNING,
                userIdToMessage,
                messageProvider.consecutiveWarningSubText(),
                null
        );

        notificationPushSender.pushEach(userIdToMessage, NotificationType.CONSECUTIVE_LEARNING_WARNING.toPushData());
    }

    public void sendDailyIncompleteReminders() {
        List<Long> targetUserIds = learningQueryService.getDailyIncompleteUserIds();

        if (targetUserIds.isEmpty()) {
            return;
        }

        Map<Long, String> userIdToMessage = targetUserIds.stream()
                .collect(Collectors.toMap(userId -> userId, userId -> messageProvider.randomDailyIncomplete()));

        notificationService.notifyEach(NotificationType.DAILY_INCOMPLETE, userIdToMessage, null, null);
        notificationPushSender.pushEach(userIdToMessage, NotificationType.DAILY_INCOMPLETE.toPushData());
    }

    public void sendInactivityReminders() {
        Map<String, String> data = NotificationType.INACTIVITY.toPushData();

        for (InactivityMilestoneDto milestone : messageProvider.inactivityMilestones()) {
            List<Long> targetUserIds = userAccessService.getUserIdsInactiveForExactly(milestone.days());

            if (targetUserIds.isEmpty()) {
                continue;
            }

            notificationService.notifyUsers(targetUserIds, NotificationType.INACTIVITY, milestone.message());
            notificationPushSender.pushToUsers(targetUserIds, data, milestone::message);
        }
    }

    public void sendSeasonEndingReminders() {
        Optional<LocalDateTime> endsAt = seasonService.getActiveSeasonEndsAt();

        if (endsAt.isEmpty()) {
            return;
        }

        long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(clock), endsAt.get().toLocalDate());

        messageProvider.seasonEndingMilestones().stream()
                .filter(milestone -> milestone.daysBefore() == daysRemaining)
                .findFirst()
                .ifPresent(milestone -> {
                    notificationService.notifyAllUsers(NotificationType.SEASON_ENDING, milestone.headline(), milestone.subText(), null);
                    notificationPushSender.broadcastToAll(NotificationType.SEASON_ENDING.toPushData(), milestone.headline());
                });
    }

    public void sendSeasonResetAlerts() {
        boolean rolledOverToday = seasonService.getActiveSeasonStartsAt()
                .map(startsAt -> startsAt.toLocalDate().isEqual(LocalDate.now(clock)))
                .orElse(false);

        if (!rolledOverToday) {
            return;
        }

        String message = messageProvider.seasonReset();
        notificationService.notifyAllUsers(NotificationType.SEASON_RESET, message, null, null);
        notificationPushSender.broadcastToAll(NotificationType.SEASON_RESET.toPushData(), message);
    }

    public void sendNewContentAlerts(long unitId) {
        notificationService.notifyAllUsers(NotificationType.NEW_CONTENT, messageProvider.newContent(), null, unitId);
    }
}
