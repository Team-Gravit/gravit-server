package gravit.code.social.facade;

import static gravit.code.global.exception.domain.CustomErrorCode.CANNOT_CONGRATULATE_OWN_FEED;
import static gravit.code.global.exception.domain.CustomErrorCode.CONGRATULATE_LIMIT_EXCEEDED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

import gravit.code.friend.fixture.FriendFixture;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.notification.domain.Notification;
import gravit.code.notification.repository.NotificationRepository;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.social.domain.SocialFeed;
import gravit.code.social.dto.response.RecommendUserResponse;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.fixture.SocialFeedFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class SocialFacadeIntegrationTest {

    @Autowired
    private SocialFacade socialFacade;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private FriendFixture friendFixture;

    @Autowired
    private SocialFeedFixture socialFeedFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Nested
    @DisplayName("피드를 조회할 때")
    class GetFeed {

        @Test
        void 팔로이가_없으면_빈_결과를_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);

            // when
            SliceResponse<SocialFeedResponse> result = socialFacade.getFeed(requester.getId(), 0);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).isEmpty();
                softly.assertThat(result.hasNextPage()).isFalse();
            });
        }

        @Test
        void 팔로이가_있으면_팔로이의_피드를_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, followee);
            SocialFeed feed = socialFeedFixture.레벨업_피드(followee.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFacade.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents()).hasSize(1);
            SocialFeedResponse response = result.contents().get(0);
            assertSoftly(softly -> {
                softly.assertThat(response.feedId()).isEqualTo(feed.getId());
                softly.assertThat(response.actorId()).isEqualTo(followee.getId());
                softly.assertThat(response.actorNickname()).isEqualTo("유저2");
                softly.assertThat(response.actorHandle()).isEqualTo("h2");
                softly.assertThat(response.actorProfileImgNumber()).isEqualTo(1);
                softly.assertThat(response.message()).isEqualTo("유저2님이 LV.5로 레벨업했어요!");
                softly.assertThat(response.timeAgo()).isNotNull();
                softly.assertThat(response.canCongratulate()).isTrue();
                softly.assertThat(response.createdAt()).isNotNull();
            });
        }

        @Test
        void 팔로우하지_않은_사용자의_피드는_반환하지_않는다() {
            // given
            User requester = userFixture.일반_유저(1);
            User other = userFixture.일반_유저(2);
            socialFeedFixture.레벨업_피드(other.getId(), 5);

            // when
            SliceResponse<SocialFeedResponse> result = socialFacade.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 여러_팔로이의_피드를_함께_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee1 = userFixture.일반_유저(2);
            User followee2 = userFixture.일반_유저(3);
            friendFixture.팔로우(requester, followee1);
            friendFixture.팔로우(requester, followee2);
            socialFeedFixture.레벨업_피드(followee1.getId(), 3);
            socialFeedFixture.연속학습_피드(followee2.getId(), 7);

            // when
            SliceResponse<SocialFeedResponse> result = socialFacade.getFeed(requester.getId(), 0);

            // then
            assertThat(result.contents()).hasSize(2);
            List<Long> actorIds = result.contents().stream().map(SocialFeedResponse::actorId).toList();
            assertThat(actorIds).containsExactlyInAnyOrder(followee1.getId(), followee2.getId());
        }
    }

    @Nested
    @DisplayName("피드를 숨길 때")
    class HideFeed {

        @Test
        void 숨긴_피드는_목록에서_사라진다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            friendFixture.팔로우(requester, followee);
            SocialFeed feed = socialFeedFixture.레벨업_피드(followee.getId(), 5);

            // when
            socialFacade.hideFeed(requester.getId(), feed.getId());

            // then
            SliceResponse<SocialFeedResponse> result = socialFacade.getFeed(requester.getId(), 0);
            assertThat(result.contents()).isEmpty();
        }
    }

    @Nested
    @DisplayName("피드를 축하할 때")
    class CongratulateFeed {

        private void 축하_환경_셋업(User requester, User followee) {
            friendFixture.팔로우(requester, followee);
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            userLeagueFixture.참여(followee, season, league, 0);
        }

        @Test
        void 축하한_피드는_목록에서_사라진다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            축하_환경_셋업(requester, followee);
            SocialFeed feed = socialFeedFixture.레벨업_피드(followee.getId(), 5);

            // when
            socialFacade.congratulateFeed(requester.getId(), feed.getId());

            // then
            SliceResponse<SocialFeedResponse> result = socialFacade.getFeed(requester.getId(), 0);
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 축하받은_유저에게_5LP가_지급된다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            축하_환경_셋업(requester, followee);
            SocialFeed feed = socialFeedFixture.레벨업_피드(followee.getId(), 5);

            // when
            socialFacade.congratulateFeed(requester.getId(), feed.getId());

            // then
            UserLeague updated = userLeagueRepository.findByUserId(followee.getId()).orElseThrow();
            assertThat(updated.getLp()).isEqualTo(5);
        }

        @Test
        void 축하받은_유저에게_인앱_알림이_생성된다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            축하_환경_셋업(requester, followee);
            SocialFeed feed = socialFeedFixture.레벨업_피드(followee.getId(), 5);

            // when
            socialFacade.congratulateFeed(requester.getId(), feed.getId());

            // then
            List<Notification> notifications = notificationRepository.findAll();
            assertThat(notifications).hasSize(1);
            assertSoftly(softly -> {
                softly.assertThat(notifications.get(0).getUserId()).isEqualTo(followee.getId());
                softly.assertThat(notifications.get(0).getMessage()).isEqualTo("유저1님이 축하해줬어요!");
            });
        }

        @Test
        void 자신의_피드는_축하할_수_없다() {
            // given
            User actor = userFixture.일반_유저(1);
            League league = leagueFixture.브론즈_3();
            Season season = seasonFixture.진행중인_시즌("S1");
            userLeagueFixture.참여(actor, season, league, 0);
            SocialFeed feed = socialFeedFixture.레벨업_피드(actor.getId(), 5);

            // when & then
            assertThatThrownBy(() -> socialFacade.congratulateFeed(actor.getId(), feed.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CANNOT_CONGRATULATE_OWN_FEED);
        }

        @Test
        void 하루_3회_초과_축하_시_예외가_발생한다() {
            // given
            User requester = userFixture.일반_유저(1);
            User followee = userFixture.일반_유저(2);
            축하_환경_셋업(requester, followee);
            SocialFeed feed1 = socialFeedFixture.레벨업_피드(followee.getId(), 3);
            SocialFeed feed2 = socialFeedFixture.연속학습_피드(followee.getId(), 7);
            SocialFeed feed3 = socialFeedFixture.레벨업_피드(followee.getId(), 5);
            SocialFeed feed4 = socialFeedFixture.연속학습_피드(followee.getId(), 14);

            socialFacade.congratulateFeed(requester.getId(), feed1.getId());
            socialFacade.congratulateFeed(requester.getId(), feed2.getId());
            socialFacade.congratulateFeed(requester.getId(), feed3.getId());

            // when & then
            assertThatThrownBy(() -> socialFacade.congratulateFeed(requester.getId(), feed4.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CONGRATULATE_LIMIT_EXCEEDED);
        }
    }

    @Nested
    @DisplayName("추천 유저를 조회할 때")
    class GetRecommendedUsers {

        @Test
        void 같은_티어에_5명_이상이면_같은_티어_유저만_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈 = leagueFixture.브론즈_3();   // sortOrder=1
            League 실버 = leagueFixture.실버_3();        // sortOrder=4 (폴백 범위 밖)
            userLeagueFixture.참여(requester, season, 브론즈, 0);

            User u2 = userFixture.일반_유저(2);
            User u3 = userFixture.일반_유저(3);
            User u4 = userFixture.일반_유저(4);
            User u5 = userFixture.일반_유저(5);
            User u6 = userFixture.일반_유저(6);
            User silverUser = userFixture.일반_유저(7);
            userLeagueFixture.참여(u2, season, 브론즈, 0);
            userLeagueFixture.참여(u3, season, 브론즈, 0);
            userLeagueFixture.참여(u4, season, 브론즈, 0);
            userLeagueFixture.참여(u5, season, 브론즈, 0);
            userLeagueFixture.참여(u6, season, 브론즈, 0);
            userLeagueFixture.참여(silverUser, season, 실버, 0);

            // when
            List<RecommendUserResponse> result = socialFacade.getRecommendedUsers(requester.getId());

            // then - 브론즈 5명 충족 → 폴백 없이 브론즈만 반환
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(5);
                softly.assertThat(result).extracting(RecommendUserResponse::userId)
                        .containsExactlyInAnyOrder(u2.getId(), u3.getId(), u4.getId(), u5.getId(), u6.getId());
                softly.assertThat(result).extracting(RecommendUserResponse::nickname)
                        .containsExactlyInAnyOrder("유저2", "유저3", "유저4", "유저5", "유저6");
            });
        }

        @Test
        void 이미_팔로우한_유저는_추천에서_제외된다() {
            // given
            User requester = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈 = leagueFixture.브론즈_3();
            userLeagueFixture.참여(requester, season, 브론즈, 0);

            User followedUser = userFixture.일반_유저(2);
            User notFollowedUser = userFixture.일반_유저(3);
            userLeagueFixture.참여(followedUser, season, 브론즈, 0);
            userLeagueFixture.참여(notFollowedUser, season, 브론즈, 0);
            friendFixture.팔로우(requester, followedUser);

            // when
            List<RecommendUserResponse> result = socialFacade.getRecommendedUsers(requester.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).userId()).isEqualTo(notFollowedUser.getId());
                softly.assertThat(result.get(0).nickname()).isEqualTo("유저3");
            });
        }

        @Test
        void 본인은_추천에서_제외된다() {
            // given
            User requester = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈 = leagueFixture.브론즈_3();
            userLeagueFixture.참여(requester, season, 브론즈, 0);

            // when
            List<RecommendUserResponse> result = socialFacade.getRecommendedUsers(requester.getId());

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 추천_유저는_최대_8명까지만_반환한다() {
            // given
            User requester = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈 = leagueFixture.브론즈_3();
            userLeagueFixture.참여(requester, season, 브론즈, 0);

            for (int i = 2; i <= 11; i++) {
                User u = userFixture.일반_유저(i);
                userLeagueFixture.참여(u, season, 브론즈, 0);
            }

            // when
            List<RecommendUserResponse> result = socialFacade.getRecommendedUsers(requester.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(8);
                softly.assertThat(result).extracting(RecommendUserResponse::userId)
                        .doesNotContain(requester.getId());
                softly.assertThat(result).extracting(RecommendUserResponse::nickname)
                        .doesNotContain("유저1");
            });
        }
    }
}
