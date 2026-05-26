package gravit.code.social.facade;

import gravit.code.friend.service.FriendService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notification.service.NotificationService;
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
    private final NotificationService notificationService;
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
        notificationService.notify(actorId, congratulatorNickname + "님이 축하해줬어요!");
    }
}
