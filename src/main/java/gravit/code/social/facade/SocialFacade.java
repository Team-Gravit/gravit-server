package gravit.code.social.facade;

import gravit.code.friend.service.FriendService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notification.service.NotificationCommandService;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.service.CongratulationCommandService;
import gravit.code.social.service.SocialFeedCommandService;
import gravit.code.social.service.SocialFeedQueryService;
import gravit.code.social.service.UserFeedCommandService;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeaguePointService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class SocialFacade {

    private static final int CONGRATULATION_LP = 5;
    private static final int FULL_ACCURACY = 100;

    private final SocialFeedQueryService socialFeedQueryService;
    private final SocialFeedCommandService socialFeedCommandService;
    private final UserFeedCommandService userFeedCommandService;
    private final CongratulationCommandService congratulationCommandService;
    private final FriendService friendService;
    private final UserService userService;
    private final UserLeaguePointService userLeaguePointService;
    private final NotificationCommandService notificationCommandService;

    @Transactional(readOnly = true)
    public SliceResponse<SocialFeedResponse> getFeed(
            long userId,
            int page
    ) {
        return socialFeedQueryService.getFeed(userId, page);
    }

    @Transactional
    public void publishFeed(
            long actorId,
            FeedEventType eventType,
            String eventValue
    ) {
        SocialFeed feed = socialFeedCommandService.createFeed(actorId, eventType, eventValue);
        List<Long> followerIds = friendService.getFollowerIds(actorId);
        userFeedCommandService.distributeToFollowers(feed.getId(), followerIds);
    }

    @Transactional
    public void hideFeed(
            long userId,
            long feedId
    ) {
        userFeedCommandService.hideFeed(userId, feedId);
    }

    @Transactional
    public void congratulateFeed(
            long userId,
            long feedId
    ) {
        long actorId = socialFeedQueryService.getActorId(feedId);
        if (userId == actorId) {
            throw new RestApiException(CustomErrorCode.CANNOT_CONGRATULATE_OWN_FEED);
        }
        congratulationCommandService.checkAndRecord(userId, actorId, feedId);
        userFeedCommandService.congratulateFeed(userId, feedId);
        userLeaguePointService.addLeaguePoints(actorId, CONGRATULATION_LP, FULL_ACCURACY);
        String congratulatorNickname = userService.getUser(userId).getNickname();
        notificationCommandService.notify(actorId, congratulatorNickname + "님이 축하해줬어요!");
    }
}
