package gravit.code.social.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.friend.domain.Friend;
import gravit.code.friend.repository.FriendRepository;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.fixture.SocialFeedFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class SocialFeedQueryServiceIntegrationTest {

    @Autowired
    private SocialFeedQueryService socialFeedQueryService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private FriendRepository friendRepository;

    @Autowired
    private SocialFeedFixture socialFeedFixture;

    @Nested
    @DisplayName("피드를 조회할 때")
    class GetFeed {

        @Test
        void 피드가_없으면_빈_결과를_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedQueryService.getFeed(requester.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).isEmpty();
                softly.assertThat(result.hasNextPage()).isFalse();
            });
        }

        @Test
        void 팔로이의_피드를_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendRepository.save(Friend.create(requester.getId(), actor.getId()));
            socialFeedFixture.레벨업_피드(actor.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedQueryService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents()).hasSize(1);
            assertThat(result.contents().get(0).actorId()).isEqualTo(actor.getId());
        }

        @Test
        void 팔로우하지_않은_사용자의_피드는_반환하지_않는다() {
            // given
            User requester = userFixture.일반_유저(1);
            User other = userFixture.일반_유저(2);
            socialFeedFixture.레벨업_피드(other.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedQueryService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 피드_수가_PAGE_SIZE를_초과하면_hasNextPage가_true이다() {
            // given — PAGE_SIZE = 4, 피드 5개
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendRepository.save(Friend.create(requester.getId(), actor.getId()));
            for (int i = 1; i <= 5; i++) {
                socialFeedFixture.레벨업_피드(actor.getId(), i);
            }

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedQueryService.getFeed(requester.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(4);
                softly.assertThat(result.hasNextPage()).isTrue();
            });
        }

        @Test
        void 두_번째_페이지_조회_시_나머지_피드를_반환한다() {
            // given — 피드 5개, 두 번째 페이지에 1개
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendRepository.save(Friend.create(requester.getId(), actor.getId()));
            for (int i = 1; i <= 5; i++) {
                socialFeedFixture.레벨업_피드(actor.getId(), i);
            }

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedQueryService.getFeed(requester.getId(), 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.hasNextPage()).isFalse();
            });
        }

        @Test
        void 음수_페이지는_0으로_보정되어_조회된다() {
            // given
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendRepository.save(Friend.create(requester.getId(), actor.getId()));
            socialFeedFixture.레벨업_피드(actor.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedQueryService.getFeed(requester.getId(), -5);

            // then
            assertThat(result.contents()).hasSize(1);
        }
    }
}
