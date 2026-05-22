package gravit.code.social.facade;

import gravit.code.friend.service.FriendService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.service.SocialFeedQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class SocialFacade {

    private final FriendService friendService;
    private final SocialFeedQueryService socialFeedQueryService;

    @Transactional(readOnly = true)
    public SliceResponse<SocialFeedResponse> getFeed(
            long requesterId,
            int page
    ) {
        List<Long> followeeIds = friendService.getFolloweeIds(requesterId);
        return socialFeedQueryService.getFeed(followeeIds, page);
    }
}
