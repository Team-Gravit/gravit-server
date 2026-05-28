package gravit.code.friend.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.fixture.FriendFixture;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class FriendServiceTest {

    @Autowired
    private FriendService friendService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private FriendFixture friendFixture;

    @Test
    void 나를_팔로우한_사람을_내가_팔로우하지_않으면_isFollowing이_false다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        friendFixture.팔로우(follower, me);

        // when
        SliceResponse<FollowerResponse> result = friendService.getFollowers(me.getId(), 0);

        // then
        assertThat(result.contents()).hasSize(1);
        assertThat(result.contents().get(0).id()).isEqualTo(follower.getId());
        assertThat(result.contents().get(0).isFollowing()).isFalse();
    }

    @Test
    void 나를_팔로우한_사람을_내가도_팔로우하면_isFollowing이_true다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        friendFixture.팔로우(follower, me);
        friendFixture.팔로우(me, follower);

        // when
        SliceResponse<FollowerResponse> result = friendService.getFollowers(me.getId(), 0);

        // then
        assertThat(result.contents()).hasSize(1);
        assertThat(result.contents().get(0).isFollowing()).isTrue();
    }

    @Test
    void 팔로워_목록에서_맞팔과_단방향_팔로워가_혼재할_때_isFollowing이_각각_올바르게_반환된다() {
        // given
        User me = userFixture.일반_유저(1);
        User mutualFollower = userFixture.일반_유저(2);
        User oneWayFollower = userFixture.일반_유저(3);

        friendFixture.팔로우(mutualFollower, me);
        friendFixture.팔로우(me, mutualFollower); // 맞팔
        friendFixture.팔로우(oneWayFollower, me); // 단방향

        // when
        SliceResponse<FollowerResponse> result = friendService.getFollowers(me.getId(), 0);

        // then
        assertThat(result.contents()).hasSize(2);
        List<FollowerResponse> contents = result.contents();

        FollowerResponse mutual = contents.stream()
                .filter(r -> r.id() == mutualFollower.getId())
                .findFirst().orElseThrow();
        FollowerResponse oneWay = contents.stream()
                .filter(r -> r.id() == oneWayFollower.getId())
                .findFirst().orElseThrow();

        assertThat(mutual.isFollowing()).isTrue();
        assertThat(oneWay.isFollowing()).isFalse();
    }

    @Test
    void 팔로워가_없으면_빈_목록을_반환한다() {
        // given
        User me = userFixture.일반_유저(1);

        // when
        SliceResponse<FollowerResponse> result = friendService.getFollowers(me.getId(), 0);

        // then
        assertThat(result.contents()).isEmpty();
        assertThat(result.hasNextPage()).isFalse();
    }

    @Test
    void 자기_자신에게_팔로잉하면_예외가_발생한다() {
        // given
        User me = userFixture.일반_유저(1);

        // when & then
        assertThatThrownBy(() -> friendService.following(me.getId(), me.getId()))
                .isInstanceOf(RestApiException.class);
    }

    @Test
    void 이미_팔로잉_중인_유저에게_팔로잉하면_예외가_발생한다() {
        // given
        User me = userFixture.일반_유저(1);
        User target = userFixture.일반_유저(2);
        friendFixture.팔로우(me, target);

        // when & then
        assertThatThrownBy(() -> friendService.following(me.getId(), target.getId()))
                .isInstanceOf(RestApiException.class);
    }

    @Test
    void 팔로잉_취소_시_팔로워_목록에서_제거된다() {
        // given
        User me = userFixture.일반_유저(1);
        User follower = userFixture.일반_유저(2);
        friendFixture.팔로우(me, follower);

        // when
        friendService.unFollowing(me.getId(), follower.getId());

        // then
        SliceResponse<FollowerResponse> result = friendService.getFollowers(follower.getId(), 0);
        assertThat(result.contents()).isEmpty();
    }
}
