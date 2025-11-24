//package gravit.code.friend.service;
//
//import gravit.code.friend.domain.Friend;
//import gravit.code.friend.domain.FriendRepository;
//import gravit.code.friend.dto.response.FollowerResponse;
//import gravit.code.friend.dto.response.FollowingResponse;
//import gravit.code.friend.dto.response.FriendResponse;
//import gravit.code.global.dto.response.SliceResponse;
//import gravit.code.support.TCSpringBootTest;
//import gravit.code.user.domain.Role;
//import gravit.code.user.domain.User;
//import gravit.code.user.domain.UserRepository;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.data.domain.PageRequest;
//import org.springframework.data.domain.Pageable;
//import org.springframework.data.domain.Slice;
//import org.springframework.test.context.jdbc.Sql;
//
//import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
//import static org.junit.jupiter.api.Assertions.*;
//
//@TCSpringBootTest
//@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
//class FriendServiceTest {
//
//    @Autowired
//    private FriendService friendService;
//
//    @Autowired
//    private UserRepository userRepository;
//
//    @Autowired
//    private FriendRepository friendRepository;
//
//    @Test
//    void 상호_팔로우_가능한지_검증() {
//        // given
//        User user1 = User.create("user1@example.com", "kakao1231513141231", "User1", "@user1", 1, Role.USER);
//        userRepository.save(user1);
//        User user2 = User.create("user2@example.com", "google123677438112", "User2", "@user2", 2, Role.USER);
//        userRepository.save(user2);
//
//        // when
//        FriendResponse response1 = friendService.following(user1.getId(), user2.getId()); // user2 -> user1
//        FriendResponse response2 = friendService.following(user2.getId(), user1.getId()); // user1 -> user2
//
//
//        // then
//        assertEquals(response1.followerId(), user1.getId());
//        assertEquals(response1.followeeId(), user2.getId());
//
//        assertEquals(response2.followerId(), user2.getId());
//        assertEquals(response2.followeeId(), user1.getId());
//
//        // 추가 검증
//        assertTrue(friendRepository.existsByFollowerIdAndFolloweeId(user1.getId(), user2.getId()));
//        assertTrue(friendRepository.existsByFollowerIdAndFolloweeId(user2.getId(), user1.getId()));
//
//    }
//
//    @Test
//    void 팔로잉을_한_유저를_대상으로_팔로잉을_취소합니다() {
//        // given
//        User user1 = User.create("user1@example.com", "kakao1231513141231", "User1", "@user1", 1,Role.USER);
//        userRepository.save(user1);
//        User user2 = User.create("user2@example.com", "google123677438112", "User2", "@user2", 2, Role.USER);
//        userRepository.save(user2);
//        friendService.following(user1.getId(), user2.getId());
//        Pageable pageable = PageRequest.of(0, 10);
//
//        // when
//        friendService.unFollowing(user1.getId(), user2.getId());
//
//        // then
//        Slice<FollowingResponse> followings = friendRepository.findFollowingsByFollowerId(user1.getId(), pageable);
//        assertThat(followings.getContent().isEmpty()).isTrue();
//    }
//
//    @Test
//    void 나를_팔로우_한_사람들을_조회합니다() {
//        // given
//        User user1 = User.create("user1@example.com", "kakao1231513141231", "User1", "@user1", 1, Role.USER);
//        userRepository.save(user1);
//        User user2 = User.create("user2@example.com", "kakao1258853439443", "User2", "@user2", 1, Role.USER);
//        userRepository.save(user2);
//        User user3 = User.create("user3@example.com", "kakao6438123471324", "User3", "@user3", 1, Role.USER);
//        userRepository.save(user3);
//
//        Friend friend1 = Friend.create(user1.getId(), user2.getId());
//        friendRepository.save(friend1);
//        Friend friend2 = Friend.create(user1.getId(), user3.getId());
//        friendRepository.save(friend2);
//        Friend friend3 = Friend.create(user2.getId(), user1.getId());
//        friendRepository.save(friend3);
//        Friend friend4 = Friend.create(user3.getId(), user1.getId());
//        friendRepository.save(friend4);
//
//        // when
//        SliceResponse<FollowerResponse> followerResponses = friendService.getFollowers(user1.getId(), 0);
//
//        // then
//        assertEquals(2, followerResponses.contents().size());
//        for (FollowerResponse followerResponse : followerResponses.contents()) {
//            assertNotNull(followerResponse.nickname());
//            assertNotNull(followerResponse.handle());
//            assertTrue(followerResponse.profileImgNumber() > 0);
//        }
//    }
//
//    @Test
//    void 내가_팔로우_한_사람들을_조회합니다() {
//        // given
//        User user1 = User.create("user1@example.com", "kakao1231513141231", "User1", "@user1", 1, Role.USER);
//        userRepository.save(user1);
//        User user2 = User.create("user2@example.com", "kakao1258853439443", "User2", "@user2", 1, Role.USER);
//        userRepository.save(user2);
//        User user3 = User.create("user3@example.com", "kakao6438123471324", "User3", "@user3", 1, Role.USER);
//        userRepository.save(user3);
//
//        Friend friend1 = Friend.create(user1.getId(), user2.getId());
//        friendRepository.save(friend1);
//        Friend friend2 = Friend.create(user1.getId(), user3.getId());
//        friendRepository.save(friend2);
//        Friend friend3 = Friend.create(user2.getId(), user1.getId());
//        friendRepository.save(friend3);
//        Friend friend4 = Friend.create(user3.getId(), user1.getId());
//        friendRepository.save(friend4);
//
//        // when
//        SliceResponse<FollowingResponse> followingResponses = friendService.getFollowings(user1.getId(), 0);
//
//        // then
//        assertEquals(2, followingResponses.contents().size());
//
//        for (FollowingResponse followingResponse : followingResponses.contents()) {
//            assertNotNull(followingResponse.nickname());
//            assertNotNull(followingResponse.handle());
//            assertTrue(followingResponse.profileImgNumber() > 0);
//        }
//    }
//}