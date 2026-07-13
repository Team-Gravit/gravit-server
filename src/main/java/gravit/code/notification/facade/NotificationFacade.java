package gravit.code.notification.facade;

import gravit.code.fcm.dto.internal.PushMessage;
import gravit.code.fcm.service.FcmService;
import gravit.code.fcm.service.FcmTokenQueryService;
import gravit.code.friend.service.FriendService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUser;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationActionType;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.internal.InactivityMilestone;
import gravit.code.notification.dto.internal.SeasonEndingMilestone;
import gravit.code.notification.dto.response.NotificationActor;
import gravit.code.notification.dto.response.NotificationResponse;
import gravit.code.notification.service.NotificationQueryService;
import gravit.code.notification.service.NotificationService;
import gravit.code.social.service.CongratulationService;
import gravit.code.global.util.TimeAgoFormatter;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.notification.support.NotificationPushSender;
import gravit.code.season.service.SeasonService;
import gravit.code.user.dto.response.UserSummaryResponse;
import gravit.code.user.service.UserAccessService;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import org.springframework.transaction.annotation.Transactional;

@Facade
@RequiredArgsConstructor
public class NotificationFacade {

    private final LearningQueryService learningQueryService;
    private final UserAccessService userAccessService;
    private final FcmTokenQueryService fcmTokenQueryService;
    private final FcmService fcmService;
    private final NotificationMessageProvider messageProvider;
    private final NotificationPushSender notificationPushSender;
    private final TimeAgoFormatter timeAgoFormatter;
    private final NotificationService notificationService;
    private final NotificationQueryService notificationQueryService;
    private final FriendService friendService;
    private final SeasonService seasonService;
    private final UserService userService;
    private final CongratulationService congratulationService;
    private final Clock clock;

    // 3.1 연속학습 끊길 위기: 인앱 알림함 적재(개인화 헤드라인 + 서브텍스트) + 안드로이드 푸시
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

        pushEach(messageByUserId, NotificationType.CONSECUTIVE_LEARNING_WARNING.toPushData());
    }

    // 3.2 오늘 학습 미완료: 유저별 랜덤 문구를 한 번만 뽑아 인앱·푸시에 동일하게 사용
    public void sendDailyIncompleteReminders() {

        List<Long> targetUserIds = learningQueryService.getDailyIncompleteUserIds();

        if (targetUserIds.isEmpty()) {
            return;
        }

        Map<Long, String> messageByUserId = targetUserIds.stream()
                .collect(Collectors.toMap(userId -> userId, userId -> messageProvider.randomDailyIncomplete()));

        notificationService.notifyEach(NotificationType.DAILY_INCOMPLETE, messageByUserId, null, null);

        pushEach(messageByUserId, NotificationType.DAILY_INCOMPLETE.toPushData());
    }

    // 3.3 장기 미접속: 마일스톤 단위로 인앱 알림함 적재 + 안드로이드 푸시
    public void sendInactivityReminders() {

        Map<String, String> data = NotificationType.INACTIVITY.toPushData();

        for (InactivityMilestone milestone : messageProvider.inactivityMilestones()) {
            List<Long> targetUserIds = userAccessService.getUserIdsInactiveForExactly(milestone.days());

            if (targetUserIds.isEmpty()) {
                continue;
            }

            notificationService.notifyUsers(targetUserIds, NotificationType.INACTIVITY, milestone.message());
            pushToUsers(targetUserIds, data, milestone::message);
        }
    }

    // 3.13 새 콘텐츠: 인앱 알림함에만 적재(인앱 only, 푸시 미발송). targetId = 새 레슨 unitId(딥링크용)
    public void sendNewContentAlerts(long unitId) {
        notificationService.notifyAllUsers(NotificationType.NEW_CONTENT, messageProvider.newContent(), null, unitId);
    }

    // 3.7 시즌 종료 임박: ACTIVE 시즌의 종료일까지 남은 일수가 마일스톤(7일/3일)과 일치하면 전체 발송(인앱 + 푸시)
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
                    broadcastToAll(NotificationType.SEASON_ENDING.toPushData(), milestone.headline());
                });
    }

    // 3.8 시즌 종료 + 새 시즌 시작: 자정 롤오버 직후 새벽 푸시를 피하기 위해 다음날(=롤오버 당일) 오전 9시 스케줄에서 발송.
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
        broadcastToAll(NotificationType.SEASON_RESET.toPushData(), message);
    }

    // 인앱 알림함에만 적재 (푸시 미발송) — 3.9 팔로우 / 3.10 축하하기 / 3.11 친구 활동
    public void notifyUserInApp(
            long userId,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notify(userId, type, message, targetId);
    }

    public void notifyUsersInApp(
            List<Long> userIds,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notifyUsers(userIds, type, message, targetId);
    }

    // 특정 유저에게 인앱 알림 저장 + FCM 푸시 발송 (인앱 + 푸시 모두 쓰는 알림용)
    public void notifyUser(
            long userId,
            NotificationType type,
            String message
    ) {
        notifyUser(userId, type, message, null);
    }

    public void notifyUser(
            long userId,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notify(userId, type, message, targetId);
        notificationPushSender.pushToUser(userId, type.toPushData(targetId), message);
    }

    // 여러 유저에게 인앱 알림 저장 + FCM 푸시 발송
    public void notifyUsers(
            List<Long> userIds,
            NotificationType type,
            String message
    ) {
        notifyUsers(userIds, type, message, null);
    }

    public void notifyUsers(
            List<Long> userIds,
            NotificationType type,
            String message,
            Long targetId
    ) {
        notificationService.notifyUsers(userIds, type, message, targetId);
        pushToUsers(userIds, type.toPushData(targetId), () -> message);
    }

    @Transactional(readOnly = true)
    public List<NotificationResponse> getInbox(long userId) {

        List<Notification> notifications = notificationQueryService.getNotifications(userId);

        Set<Long> followTargetIds = notifications.stream()
                .filter(n -> n.getType() == NotificationType.FOLLOW && n.getTargetId() != null)
                .map(Notification::getTargetId)
                .collect(Collectors.toSet());

        Set<Long> alreadyFollowing = followTargetIds.isEmpty()
                ? Collections.emptySet()
                : friendService.followingIdsAmong(userId, followTargetIds);

        Map<Long, UserSummaryResponse> actorsByUserId = userService.getUserSummaries(followTargetIds);

        // FRIEND_ACTIVITY 알림의 targetId는 곧 feedId. 소셜 피드와 동일한 Congratulation 데이터를 읽어
        // 어느 쪽에서 축하하든 축하 완료 상태가 양쪽에 동기화되도록 한다.
        Set<Long> friendActivityFeedIds = notifications.stream()
                .filter(n -> n.getType() == NotificationType.FRIEND_ACTIVITY && n.getTargetId() != null)
                .map(Notification::getTargetId)
                .collect(Collectors.toSet());

        Set<Long> congratulatedFeedIds = friendActivityFeedIds.isEmpty()
                ? Collections.emptySet()
                : congratulationService.getCongratulatedFeedIds(userId, List.copyOf(friendActivityFeedIds));

        return notifications.stream()
                .map(n -> toResponse(n, alreadyFollowing, actorsByUserId, congratulatedFeedIds))
                .toList();
    }

    private NotificationResponse toResponse(
            Notification notification,
            Set<Long> alreadyFollowing,
            Map<Long, UserSummaryResponse> actorsByUserId,
            Set<Long> congratulatedFeedIds
    ) {
        boolean isFollow = notification.getType() == NotificationType.FOLLOW
                && notification.getTargetId() != null;

        boolean isFriendActivity = notification.getType() == NotificationType.FRIEND_ACTIVITY
                && notification.getTargetId() != null;

        // 이미 팔로우 중인 상대면 버튼 없음(NONE), 아직이면 맞팔로우(FOLLOW_BACK)
        NotificationActionType actionType = isFollow
                ? (alreadyFollowing.contains(notification.getTargetId())
                        ? NotificationActionType.NONE
                        : NotificationActionType.FOLLOW_BACK)
                : notification.getType().getActionType();

        NotificationActor actor = isFollow
                ? toActor(actorsByUserId.get(notification.getTargetId()))
                : null;

        Boolean congratulated = isFriendActivity
                ? congratulatedFeedIds.contains(notification.getTargetId())
                : null;

        String timeAgo = timeAgoFormatter.format(notification.getCreatedAt());

        return NotificationResponse.of(notification, actionType, actor, congratulated, timeAgo);
    }

    private NotificationActor toActor(UserSummaryResponse summary) {
        if (summary == null) {
            return null;
        }
        return new NotificationActor(summary.id(), summary.nickname(), summary.profileImgNumber());
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

    // 유저별로 다른 문구를 푸시할 때 사용 (연속학습 위기·오늘 미완료)
    private void pushEach(
            Map<Long, String> messageByUserId,
            Map<String, String> data
    ) {
        Map<Long, List<String>> tokensByUserId = fcmTokenQueryService.getTokensByUserIds(List.copyOf(messageByUserId.keySet()));

        List<PushMessage> messages = messageByUserId.entrySet().stream()
                .filter(entry -> tokensByUserId.containsKey(entry.getKey()))
                .map(entry -> PushMessage.of(
                        tokensByUserId.get(entry.getKey()),
                        entry.getValue(),
                        null,
                        data
                ))
                .toList();

        fcmService.sendNotifications(messages);
    }
}
