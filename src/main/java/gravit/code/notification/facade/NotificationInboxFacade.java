package gravit.code.notification.facade;

import gravit.code.friend.service.FriendService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.util.TimeAgoFormatter;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationActionType;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.dto.response.NotificationActor;
import gravit.code.notification.dto.response.NotificationResponse;
import gravit.code.notification.service.NotificationQueryService;
import gravit.code.social.service.CongratulationService;
import gravit.code.user.dto.response.UserSummaryResponse;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Facade
@RequiredArgsConstructor
public class NotificationInboxFacade {

    private final NotificationQueryService notificationQueryService;
    private final FriendService friendService;
    private final UserService userService;
    private final CongratulationService congratulationService;
    private final TimeAgoFormatter timeAgoFormatter;

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
}
