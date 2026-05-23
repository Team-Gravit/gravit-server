package gravit.code.social.service;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_FEED_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.social.domain.UserFeed;
import gravit.code.social.fixture.UserFeedFixture;
import gravit.code.social.repository.UserFeedRepository;
import gravit.code.support.TCSpringBootTest;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class UserFeedServiceIntegrationTest {

    @Autowired
    private UserFeedService userFeedService;

    @Autowired
    private UserFeedFixture userFeedFixture;

    @Autowired
    private UserFeedRepository userFeedRepository;

    @Nested
    @DisplayName("팔로워에게 피드를 배포할 때")
    class DistributeToFollowers {

        @Test
        void 팔로워_목록이_비어있으면_UserFeed가_생성되지_않는다() {
            // given & when
            userFeedService.distributeToFollowers(999L, List.of());

            // then
            assertThat(userFeedRepository.findAll()).isEmpty();
        }

        @Test
        void 단일_팔로워에게_UserFeed가_생성된다() {
            // given
            long feedId = 999L;
            long followerId = 1L;

            // when
            userFeedService.distributeToFollowers(feedId, List.of(followerId));

            // then
            List<UserFeed> userFeeds = userFeedRepository.findAll();
            assertThat(userFeeds).hasSize(1);
            assertSoftly(softly -> {
                softly.assertThat(userFeeds.get(0).getUserId()).isEqualTo(followerId);
                softly.assertThat(userFeeds.get(0).getFeedId()).isEqualTo(feedId);
                softly.assertThat(userFeeds.get(0).isHidden()).isFalse();
            });
        }

        @Test
        void 여러_팔로워_모두에게_UserFeed가_생성된다() {
            // given
            long feedId = 999L;
            List<Long> followerIds = List.of(1L, 2L, 3L);

            // when
            userFeedService.distributeToFollowers(feedId, followerIds);

            // then
            assertThat(userFeedRepository.findAll()).hasSize(3);
        }
    }

    @Nested
    @DisplayName("피드를 숨길 때")
    class HideFeed {

        @Test
        void 피드가_숨겨진다() {
            // given
            UserFeed userFeed = userFeedFixture.기본_유저피드(1L, 999L);

            // when
            userFeedService.hideFeed(1L, 999L);

            // then
            UserFeed updated = userFeedRepository.findById(userFeed.getId()).orElseThrow();
            assertThat(updated.isHidden()).isTrue();
        }

        @Test
        void 존재하지_않는_UserFeed면_예외가_발생한다() {
            // given && when && then
            assertThatThrownBy(() -> userFeedService.hideFeed(99L, 99L))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(USER_FEED_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("피드를 축하할 때")
    class CongratullateFeed {

        @Test
        void 피드가_축하되고_숨겨진다() {
            // given
            UserFeed userFeed = userFeedFixture.기본_유저피드(1L, 999L);

            // when
            userFeedService.congratulateFeed(1L, 999L);

            // then
            UserFeed updated = userFeedRepository.findById(userFeed.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(updated.getCongratulatedAt()).isNotNull();
                softly.assertThat(updated.isHidden()).isTrue();
            });
        }

        @Test
        void 존재하지_않는_UserFeed면_예외가_발생한다() {
            // given & when & then
            assertThatThrownBy(() -> userFeedService.congratulateFeed(99L, 99L))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(USER_FEED_NOT_FOUND);
        }
    }
}
