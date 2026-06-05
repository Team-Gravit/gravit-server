package gravit.code.notification.facade;

import gravit.code.fcm.dto.internal.PushMessage;
import gravit.code.fcm.service.FcmService;
import gravit.code.fcm.service.FcmTokenQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUser;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.internal.InactivityMilestone;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.season.service.SeasonService;
import gravit.code.user.service.UserAccessService;
import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Supplier;
import lombok.RequiredArgsConstructor;

@Facade
@RequiredArgsConstructor
public class NotificationFacade {

    private final LearningQueryService learningQueryService;
    private final UserAccessService userAccessService;
    private final FcmTokenQueryService fcmTokenQueryService;
    private final FcmService fcmService;
    private final NotificationMessageProvider messageProvider;
    private final SeasonService seasonService;
    private final Clock clock;

    public void sendConsecutiveLearningWarnings() {

        List<ConsecutiveAtRiskUser> targets = learningQueryService.getConsecutiveAtRiskUsers();

        if (targets.isEmpty()) {
            return;
        }

        List<Long> targetUserIds = targets.stream()
                .map(ConsecutiveAtRiskUser::userId)
                .toList();

        Map<Long, List<String>> tokensByUserId = fcmTokenQueryService.getTokensByUserIds(targetUserIds);

        Map<String, String> data = NotificationType.CONSECUTIVE_LEARNING_WARNING.toPushData();

        List<PushMessage> messages = targets.stream()
                .filter(target -> tokensByUserId.containsKey(target.userId()))
                .map(target -> PushMessage.of(
                        tokensByUserId.get(target.userId()),
                        messageProvider.consecutiveWarning(target.consecutiveSolvedDays()),
                        null,
                        data
                ))
                .toList();

        fcmService.sendNotifications(messages);
    }

    public void sendDailyIncompleteReminders() {

        List<Long> targetUserIds = learningQueryService.getDailyIncompleteUserIds();

        if (targetUserIds.isEmpty()) {
            return;
        }

        pushToUsers(targetUserIds, NotificationType.DAILY_INCOMPLETE.toPushData(), messageProvider::randomDailyIncomplete);
    }

    public void sendInactivityReminders() {

        Map<String, String> data = NotificationType.INACTIVITY.toPushData();

        for (InactivityMilestone milestone : messageProvider.inactivityMilestones()) {
            List<Long> targetUserIds = userAccessService.getUserIdsInactiveForExactly(milestone.days());

            if (targetUserIds.isEmpty()) {
                continue;
            }

            pushToUsers(targetUserIds, data, milestone::message);
        }
    }

    public void sendNewContentAlerts(long unitId) {

        List<String> tokens = fcmTokenQueryService.getAllTokens();

        if (tokens.isEmpty()) {
            return;
        }

        PushMessage message = PushMessage.of(
                tokens,
                messageProvider.newContent(),
                null,
                NotificationType.NEW_CONTENT.toPushData(unitId)
        );

        fcmService.sendNotifications(List.of(message));
    }

    // 시즌 종료 임박: ACTIVE 시즌의 종료일까지 남은 일수가 마일스톤(7일/3일)과 일치하면 전체 발송
    public void sendSeasonEndingReminders() {

        Optional<LocalDateTime> endsAt = seasonService.getActiveSeasonEndsAt();

        if (endsAt.isEmpty()) {
            return;
        }

        long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(clock), endsAt.get().toLocalDate());

        messageProvider.seasonEndingMilestones().stream()
                .filter(milestone -> milestone.daysBefore() == daysRemaining)
                .findFirst()
                .ifPresent(milestone -> broadcastToAll(
                        NotificationType.SEASON_ENDING.toPushData(),
                        milestone.message()
                ));
    }

    // 시즌 종료 + 새 시즌 시작: 롤오버 직후 전체 발송 (소프트 리셋 결과는 알림에 포함하지 않음)
    public void sendSeasonResetAlerts() {
        broadcastToAll(NotificationType.SEASON_RESET.toPushData(), messageProvider.seasonReset());
    }

    public void sendConsecutiveLearningWarningToUser(
            long userId,
            int consecutiveDays
    ) {
        pushToUser(
                userId,
                NotificationType.CONSECUTIVE_LEARNING_WARNING.toPushData(),
                messageProvider.consecutiveWarning(consecutiveDays)
        );
    }

    public void sendDailyIncompleteToUser(long userId) {
        pushToUser(
                userId,
                NotificationType.DAILY_INCOMPLETE.toPushData(),
                messageProvider.randomDailyIncomplete()
        );
    }

    public void sendInactivityToUser(
            long userId,
            int inactiveDays
    ) {
        pushToUser(
                userId,
                NotificationType.INACTIVITY.toPushData(),
                messageProvider.inactivity(inactiveDays)
        );
    }

    public void sendNewContentToUser(
            long userId,
            long unitId
    ) {
        pushToUser(
                userId,
                NotificationType.NEW_CONTENT.toPushData(unitId),
                messageProvider.newContent()
        );
    }

    private void broadcastToAll(
            Map<String, String> data,
            String message
    ) {
        List<String> tokens = fcmTokenQueryService.getAllTokens();

        if (tokens.isEmpty()) {
            return;
        }

        PushMessage pushMessage = PushMessage.of(tokens, message, null, data);

        fcmService.sendNotifications(List.of(pushMessage));
    }

    private void pushToUser(
            long userId,
            Map<String, String> data,
            String message
    ) {
        List<String> tokens = fcmTokenQueryService.getTokensByUserIds(List.of(userId))
                .get(userId);

        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        PushMessage pushMessage = PushMessage.of(tokens, message, null, data);

        fcmService.sendNotifications(List.of(pushMessage));
    }

    private void pushToUsers(
            List<Long> userIds,
            Map<String, String> data,
            Supplier<String> messageSupplier
    ) {
        Map<Long, List<String>> tokensByUserId = fcmTokenQueryService.getTokensByUserIds(userIds);

        List<PushMessage> messages = userIds.stream()
                .filter(tokensByUserId::containsKey)
                .map(userId -> PushMessage.of(
                        tokensByUserId.get(userId),
                        messageSupplier.get(),
                        null,
                        data
                ))
                .toList();

        fcmService.sendNotifications(messages);
    }
}
