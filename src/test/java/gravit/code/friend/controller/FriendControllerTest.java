package gravit.code.friend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.common.auth.WithMockLoginUser;
import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
@AutoConfigureTestDatabase
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
public class FriendControllerTest {

    @Autowired
    private MockMvc mockMvc;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FriendRepository friendRepository;

    private User testUser1;
    private User testUser2;
    private User testUser3;

    @BeforeEach
    void setUp() {

        testUser1 = User.create("test1@test.com", "kakao_123123", "kang", "@qwe123",1, Role.USER);
        userRepository.save(testUser1);
        testUser2 = User.create("test2@test.com", "google_123123", "hyung", "@ewq321", 2, Role.USER);
        userRepository.save(testUser2);
        testUser3 = User.create("test3@test.com", "naver_123123", "jun", "@weq312", 3, Role.USER);
        userRepository.save(testUser3);
    }

    @Test
    @WithMockLoginUser
    void 유저는_다른_유저에게_팔로잉_을_걸_수_있다() throws Exception {
        // given
        Long followerId = testUser1.getId();
        System.out.println("followerId: " + followerId);
        Long followeeId = testUser2.getId();
        System.out.println("followeeId: " + followeeId);

        // when
        // then
        mockMvc.perform(post("/api/v1/friends/following/" + followeeId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.followeeId").value(followeeId))
                .andExpect(jsonPath("$.followerId").value(followerId));
    }

    @Test
    @WithMockLoginUser
    void 유저는_다른_유저에게_팔로잉_취소를_할_수_있다() throws Exception {
        // given
        Long followerId = testUser1.getId();
        Long followeeId = testUser3.getId();
        Friend friend = Friend.create(followerId, followeeId);
        friendRepository.save(friend);

        // when
        // then
        mockMvc.perform(post("/api/v1/friends/unfollowing/" + followeeId))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockLoginUser
    void 나를_팔로잉_한_사람들의_정보를_조회합니다() throws Exception {
        // given
        Long followeeId = testUser1.getId();
        Long follower2Id = testUser2.getId();
        Long  follower3Id = testUser3.getId();
        Friend friend1 = Friend.create(follower2Id, followeeId);
        friendRepository.save(friend1);
        Friend friend2 = Friend.create(follower3Id, followeeId);
        friendRepository.save(friend2);

        // when
        // then
        // when & then
        mockMvc.perform(get("/api/v1/friends/follower"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$.contents[0].id").isNotEmpty())
                .andExpect(jsonPath("$.contents[0].nickname").isNotEmpty())
                .andExpect(jsonPath("$.contents[0].profileImgNumber").isNotEmpty())
                .andExpect(jsonPath("$.contents[0].handle").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].id").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].nickname").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].profileImgNumber").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].handle").isNotEmpty());
    }

    @Test
    @WithMockLoginUser
    void 내가_팔로잉_한_사람들의_정보를_조회합니다() throws Exception {
        // given
        Long followerId = testUser1.getId();
        Long followee2Id = testUser2.getId();
        Long  followee3Id = testUser3.getId();
        Friend friend1 = Friend.create(followerId, followee2Id);
        friendRepository.save(friend1);
        Friend friend2 = Friend.create(followerId, followee3Id);
        friendRepository.save(friend2);

        // when
        // then
        mockMvc.perform(get("/api/v1/friends/following"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$.contents[0].id").isNotEmpty())
                .andExpect(jsonPath("$.contents[0].nickname").isNotEmpty())
                .andExpect(jsonPath("$.contents[0].profileImgNumber").isNotEmpty())
                .andExpect(jsonPath("$.contents[0].handle").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].id").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].nickname").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].profileImgNumber").isNotEmpty())
                .andExpect(jsonPath("$.contents[1].handle").isNotEmpty());

    }
}