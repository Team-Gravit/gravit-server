package gravit.code.social.facade;

import gravit.code.friend.service.FriendService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notification.domain.NotificationType;
import gravit.code.notification.facade.NotificationFacade;
import gravit.code.notification.support.NotificationMessageProvider;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.dto.internal.RecommendCandidateDto;
import gravit.code.social.dto.response.RecommendUserResponse;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.service.CongratulationService;
import gravit.code.social.service.RecommendUserService;
import gravit.code.social.service.SocialFeedService;
import gravit.code.social.service.UserFeedService;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeaguePointService;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class SocialFacade {

    private static final int CONGRATULATION_LP = 5;
    private static final int FULL_ACCURACY = 100;

    private final SocialFeedService socialFeedService;
    private final UserFeedService userFeedService;
    private final CongratulationService congratulationService;
    private final FriendService friendService;
    private final UserService userService;
    private final UserLeaguePointService userLeaguePointService;
    private final UserLeagueService userLeagueService;
    private final NotificationFacade notificationFacade;
    private final NotificationMessageProvider messageProvider;
    private final RecommendUserService recommendUserService;

    @Transactional(readOnly = true)
    public List<RecommendUserResponse> getRecommendedUsers(long userId) {
        int mainSortOrder = userLeagueService.getLeagueSortOrder(userId);
        List<RecommendCandidateDto> candidates = recommendUserService.findCandidates(userId, mainSortOrder);
        return candidates.stream()
                .map(c -> RecommendUserResponse.of(c.userId(), c.nickname(), c.profileImgNumber(), c.mutualFollowCount()))
                .toList();
    }

    @Transactional
    public void follow(
            long userId,
            long targetUserId
    ) {
        // 팔로우 알림은 FriendService.following()이 발행하는 FollowedEvent를 통해 일원화 처리된다
        friendService.following(userId, targetUserId);
    }

    @Transactional(readOnly = true)
    public SliceResponse<SocialFeedResponse> getFeed(
            long userId,
            int page
    ) {
        return socialFeedService.getFeed(userId, page);
    }

    @Transactional
    public void publishFeed(
            long actorId,
            FeedEventType eventType,
            String eventValue
    ) {
        SocialFeed feed = socialFeedService.createFeed(actorId, eventType, eventValue);
        List<Long> followerIds = friendService.getFollowerIds(actorId);
        userFeedService.distributeToFollowers(feed.getId(), followerIds);
        if (!followerIds.isEmpty()) {
            String actorNickname = userService.getUser(actorId).getNickname();
            String message = messageProvider.friendActivity(actorNickname, eventType, eventValue);
            notificationFacade.notifyUsersInApp(followerIds, NotificationType.FRIEND_ACTIVITY, message, feed.getId());
        }
    }

    @Transactional
    public void hideFeed(
            long userId,
            long feedId
    ) {
        userFeedService.hideFeed(userId, feedId);
    }

    @Transactional
    public void congratulateFeed(
            long userId,
            long feedId
    ) {
        long actorId = socialFeedService.getActorId(feedId);
        if (userId == actorId) {
            throw new RestApiException(CustomErrorCode.CANNOT_CONGRATULATE_OWN_FEED);
        }
        congratulationService.checkAndRecord(userId, actorId, feedId);
        userFeedService.congratulateFeed(userId, feedId);
        userLeaguePointService.addLeaguePoints(actorId, CONGRATULATION_LP, FULL_ACCURACY);
        String congratulatorNickname = userService.getUser(userId).getNickname();
        notificationFacade.notifyUserInApp(actorId, NotificationType.CONGRATULATION, messageProvider.congratulation(congratulatorNickname), null);
    }
}
