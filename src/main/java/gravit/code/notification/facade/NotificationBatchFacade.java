package gravit.code.notification.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUser;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.internal.InactivityMilestone;
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

    private final LearningQueryService learningQueryService;
    private final UserAccessService userAccessService;
    private final NotificationMessageProvider messageProvider;
    private final NotificationPushSender notificationPushSender;
    private final NotificationService notificationService;
    private final SeasonService seasonService;
    private final Clock clock;

    // 연속학습 끊길 위기: 인앱 알림함 적재(개인화 헤드라인 + 서브텍스트) + 안드로이드 푸시
    public void sendConsecutiveLearningWarnings() {
        List<ConsecutiveAtRiskUser> targets = learningQueryService.getConsecutiveAtRiskUsers();

        if (targets.isEmpty()) {
            return;
        }

        Map<Long, String> messageByUserId = targets.stream()
                .collect(Collectors.toMap(
                        ConsecutiveAtRiskUser::userId,
                        target -> messageProvider.consecutiveWarning(target.consecutiveSolvedDays())
                ));

        notificationService.notifyEach(
                NotificationType.CONSECUTIVE_LEARNING_WARNING,
                messageByUserId,
                messageProvider.consecutiveWarningSubText(),
                null
        );

        notificationPushSender.pushEach(messageByUserId, NotificationType.CONSECUTIVE_LEARNING_WARNING.toPushData());
    }

    // 오늘 학습 미완료: 유저별 랜덤 문구를 한 번만 뽑아 인앱·푸시에 동일하게 사용
    public void sendDailyIncompleteReminders() {
        List<Long> targetUserIds = learningQueryService.getDailyIncompleteUserIds();

        if (targetUserIds.isEmpty()) {
            return;
        }

        Map<Long, String> messageByUserId = targetUserIds.stream()
                .collect(Collectors.toMap(userId -> userId, userId -> messageProvider.randomDailyIncomplete()));

        notificationService.notifyEach(NotificationType.DAILY_INCOMPLETE, messageByUserId, null, null);
        notificationPushSender.pushEach(messageByUserId, NotificationType.DAILY_INCOMPLETE.toPushData());
    }

    // 장기 미접속: 마일스톤 단위로 인앱 알림함 적재 + 안드로이드 푸시
    public void sendInactivityReminders() {
        Map<String, String> data = NotificationType.INACTIVITY.toPushData();

        for (InactivityMilestone milestone : messageProvider.inactivityMilestones()) {
            List<Long> targetUserIds = userAccessService.getUserIdsInactiveForExactly(milestone.days());

            if (targetUserIds.isEmpty()) {
                continue;
            }

            notificationService.notifyUsers(targetUserIds, NotificationType.INACTIVITY, milestone.message());
            notificationPushSender.pushToUsers(targetUserIds, data, milestone::message);
        }
    }

    // 시즌 종료 임박: ACTIVE 시즌의 종료일까지 남은 일수가 마일스톤(7일/3일)과 일치하면 전체 발송(인앱 + 푸시)
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

    // 시즌 종료 + 새 시즌 시작: 자정 롤오버 직후 새벽 푸시를 피하기 위해 다음날(=롤오버 당일) 오전 9시 스케줄에서 발송.
    // ACTIVE 시즌이 오늘 시작됐는지(=직전 자정에 롤오버됨)로 발송 여부를 판정한다. (소프트 리셋 결과는 알림에 포함하지 않음)
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

    // 새 콘텐츠: 인앱 알림함에만 적재(인앱 only, 푸시 미발송). targetId = 새 레슨 unitId(딥링크용)
    public void sendNewContentAlerts(long unitId) {
        notificationService.notifyAllUsers(NotificationType.NEW_CONTENT, messageProvider.newContent(), null, unitId);
    }
}
