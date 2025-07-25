package gravit.code.domain.user.service;

import gravit.code.domain.friend.domain.Friend;
import gravit.code.domain.friend.domain.FriendRepository;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.user.dto.response.MyPageResponse;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@Slf4j
class UserServiceTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FriendRepository friendRepository;

    @Test
    void 마이페이지_조회_테스트() {
        // given
        User user1 = User.create("user1@example.com", "kakao1231513141231", "User1", "@user1", 1, LocalDateTime.now());
        userRepository.save(user1);
        User user2 = User.create("user2@example.com", "kakao1258853439443", "User2", "@user2", 1, LocalDateTime.now());
        userRepository.save(user2);
        User user3 = User.create("user3@example.com", "kakao6438123471324", "User3", "@user3", 1, LocalDateTime.now());
        userRepository.save(user3);

        Friend friend1 = Friend.create(user1.getId(), user2.getId());
        friendRepository.save(friend1);
        Friend friend2 = Friend.create(user1.getId(), user3.getId());
        friendRepository.save(friend2);
        Friend friend3 = Friend.create(user2.getId(), user1.getId());
        friendRepository.save(friend3);
        Friend friend4 = Friend.create(user3.getId(), user1.getId());
        friendRepository.save(friend4);

        // when
        MyPageResponse myPageResponse = userService.getMyPage(user1.getId());
        log.info("MyPageResponse 정보 : {}",myPageResponse.toString());

        // then
        assertEquals("User1", myPageResponse.nickname());
        assertEquals(1, myPageResponse.profileImgNumber());
        assertEquals("@user1", myPageResponse.handle());
        assertEquals(2, myPageResponse.following());
        assertEquals(2, myPageResponse.following());
    }
}