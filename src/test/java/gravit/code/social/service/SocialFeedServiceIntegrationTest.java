package gravit.code.social.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.friend.fixture.FriendFixture;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.social.domain.FeedEventType;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.fixture.SocialFeedFixture;
import gravit.code.social.repository.SocialFeedRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class SocialFeedServiceIntegrationTest {

    @Autowired
    private SocialFeedService socialFeedService;

    @Autowired
    private SocialFeedRepository socialFeedRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private FriendFixture friendFixture;

    @Autowired
    private SocialFeedFixture socialFeedFixture;

    @Nested
    @DisplayName("피드를 생성할 때")
    class CreateFeed {

        @Test
        void 피드가_DB에_저장된다() {
            // given
            long actorId = 1L;
            FeedEventType eventType = FeedEventType.LEVEL_UP;
            String eventValue = "5";

            // when
            socialFeedService.createFeed(actorId, eventType, eventValue);

            // then
            List<SocialFeed> feeds = socialFeedRepository.findAll();
            assertThat(feeds).hasSize(1);
            SocialFeed saved = feeds.get(0);
            assertSoftly(softly -> {
                softly.assertThat(saved.getActorId()).isEqualTo(actorId);
                softly.assertThat(saved.getEventType()).isEqualTo(eventType);
                softly.assertThat(saved.getEventValue()).isEqualTo(eventValue);
            });
        }

        @Test
        void 여러_피드를_저장할_수_있다() {
            // when
            socialFeedService.createFeed(1L, FeedEventType.LEVEL_UP, "5");
            socialFeedService.createFeed(2L, FeedEventType.STREAK_DAYS, "7");
            socialFeedService.createFeed(3L, FeedEventType.TIER_PROMOTION, "골드");

            // then
            assertThat(socialFeedRepository.findAll()).hasSize(3);
        }
    }

    @Nested
    @DisplayName("피드를 조회할 때")
    class GetFeed {

        @Test
        void 피드가_없으면_빈_결과를_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

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
            friendFixture.팔로우(requester, actor);
            socialFeedFixture.레벨업_피드(actor.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

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
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 피드_수가_PAGE_SIZE를_초과하면_hasNextPage가_true이다() {
            // given — PAGE_SIZE = 4, 피드 5개
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, actor);
            for (int i = 1; i <= 5; i++) {
                socialFeedFixture.레벨업_피드(actor.getId(), i);
            }

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

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
            friendFixture.팔로우(requester, actor);
            for (int i = 1; i <= 5; i++) {
                socialFeedFixture.레벨업_피드(actor.getId(), i);
            }

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 1);

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
            friendFixture.팔로우(requester, actor);
            socialFeedFixture.레벨업_피드(actor.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), -5);

            // then
            assertThat(result.contents()).hasSize(1);
        }
    }

    @Nested
    @DisplayName("피드 메시지를 생성할 때")
    class MessageGeneration {

        @Test
        void LEVEL_UP_메시지를_생성한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, actor);
            socialFeedFixture.레벨업_피드(actor.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents().get(0).message()).isEqualTo("유저2님이 LV.5로 레벨업했어요!");
        }

        @Test
        void STREAK_DAYS_메시지를_생성한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, actor);
            socialFeedFixture.연속학습_피드(actor.getId(), 30);

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents().get(0).message()).isEqualTo("유저2님이 30일 연속 학습을 달성했어요!");
        }

        @Test
        void TIER_PROMOTION_메시지를_생성한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, actor);
            socialFeedFixture.티어승급_피드(actor.getId(), "골드");

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents().get(0).message()).isEqualTo("유저2님이 골드로 승급했어요!");
        }

        @Test
        void PLANET_COMPLETE_메시지를_생성한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User actor = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, actor);
            socialFeedFixture.행성정복_피드(actor.getId(), "지구");

            // when
            SliceResponse<SocialFeedResponse> result = socialFeedService.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents().get(0).message()).isEqualTo("유저2님이 지구 행성을 정복했어요!");
        }
    }
}
