package gravit.code.social.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.social.domain.UserFeed;
import gravit.code.social.repository.UserFeedRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserFeedService {

    private final UserFeedRepository userFeedRepository;

    @Transactional
    public void distributeToFollowers(
            long feedId,
            List<Long> followerIds
    ) {
        if (followerIds.isEmpty()) {
            return;
        }
        List<UserFeed> userFeeds = followerIds.stream()
                .map(followerId -> UserFeed.create(followerId, feedId))
                .toList();
        userFeedRepository.saveAll(userFeeds);
    }

    @Transactional
    public void hideFeed(
            long userId,
            long feedId
    ) {
        UserFeed userFeed = userFeedRepository.findByUserIdAndFeedId(userId, feedId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_FEED_NOT_FOUND));
        userFeed.hide();
    }

    @Transactional
    public void congratulateFeed(
            long userId,
            long feedId
    ) {
        UserFeed userFeed = userFeedRepository.findByUserIdAndFeedId(userId, feedId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_FEED_NOT_FOUND));
        userFeed.congratulate();
    }
}
