package gravit.code.domain.user.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.common.auth.WithMockLoginUser;
import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeagueService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
@AutoConfigureTestDatabase
@EnableJpaAuditing
@Sql(
        scripts = {
        "classpath:sql/truncate_all.sql",
        "classpath:sql/onboard_league_data.sql"
}, executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FriendRepository friendRepository;

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @Autowired
    private UserLeagueService  userLeagueService;

    private final ObjectMapper objectMapper = new ObjectMapper();


    @Test
    @WithMockLoginUser
    void 유저ID로_유저를_조회합니다() throws Exception {
        // given
        Long userId = 1L;
        int testProfileImgNumber = 1;
        String testEmail = "test@test.com";
        String testNickname = "kang";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";

        User user = User.create(testEmail, testProviderId, testNickname,testHandle,testProfileImgNumber, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(get("/api/v1/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(userId))
                .andExpect(jsonPath("$.profileImgNumber").value(testProfileImgNumber))
                .andExpect(jsonPath("$.nickname").value(testNickname))
                .andExpect(jsonPath("$.providerId").value(testProviderId));
    }


    @Test
    @WithMockLoginUser
    void 회원가입_이후_온보딩을_진행합니다() throws Exception {
        // given
        Long userId = 1L;
        int testProfileImgNumber = 1;
        String testEmail = "test@test.com";
        String testNickname = "kang";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";
        OnboardingRequest onboardingRequest = new OnboardingRequest(testNickname, testProfileImgNumber);


        User user = User.create(testEmail, testProviderId, "test", testHandle, 0, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(post("/api/v1/users/me/onboarding")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(onboardingRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(userId))
                .andExpect(jsonPath("$.profileImgNumber").value(testProfileImgNumber))
                .andExpect(jsonPath("$.nickname").value(testNickname))
                .andExpect(jsonPath("$.providerId").value(testProviderId));
    }

    @Test
    @WithMockLoginUser
    void 닉네임_길이가_2보다_작으면_예외를_던집니다() throws Exception {
        // given
        int testProfileImgNumber = 1;
        String testEmail = "test@test.com";
        String testNickname = "k";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";
        OnboardingRequest onboardingRequest = new OnboardingRequest(testNickname, testProfileImgNumber);

        User user = User.create(testEmail, testProviderId, "test", testHandle, 0, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(post("/api/v1/users/me/onboarding")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(onboardingRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                .andExpect(jsonPath("$.message[0]").value("[ nickname ][ 닉네임은 2자 이상 8자 이하이어야 합니다. ][ " + testNickname + " ]"));
    }

    @Test
    @WithMockLoginUser
    void 닉네임이_8자보다_길_경우_예외를_던집니다() throws Exception {
        // given
        int testProfileImgNumber = 1;
        String testEmail = "test@test.com";
        String testNickname = "kangkangkang";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";
        OnboardingRequest onboardingRequest = new OnboardingRequest(testNickname, testProfileImgNumber);

        User user = User.create(testEmail, testProviderId, "test", testHandle, 0, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(post("/api/v1/users/me/onboarding")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(onboardingRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                .andExpect(jsonPath("$.message[0]").value("[ nickname ][ 닉네임은 2자 이상 8자 이하이어야 합니다. ][ " + testNickname + " ]"));
    }

    @Test
    @WithMockLoginUser
    void 프로필_이미지_아이디가_10보다_크면_예외를_던집니다() throws Exception {
        // given
        int testProfileImgNumber = 11;
        String testEmail = "test@test.com";
        String testNickname = "kang";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";
        OnboardingRequest onboardingRequest = new OnboardingRequest(testNickname, testProfileImgNumber);

        User user = User.create(testEmail, testProviderId, "test", testHandle, 0, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(post("/api/v1/users/me/onboarding")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(onboardingRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                .andExpect(jsonPath("$.message[0]").value("[ profilePhotoNumber ][ 프로필 사진 번호는 10 이하여야 합니다. ][ " + testProfileImgNumber + " ]"));
    }

    @Test
    @WithMockLoginUser
    void 프로필_이미지_아이디가_1보다_작으면_예외를_던집니다() throws Exception {
        // given
        int testProfileImgNumber = 0;
        String testEmail = "test@test.com";
        String testNickname = "kang";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";
        OnboardingRequest onboardingRequest = new OnboardingRequest(testNickname, testProfileImgNumber);

        User user = User.create(testEmail, testProviderId, "test", testHandle, 0, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(post("/api/v1/users/me/onboarding")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(onboardingRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                .andExpect(jsonPath("$.message[0]").value("[ profilePhotoNumber ][ 프로필 사진 번호는 1 이상이어야 합니다. ][ " + testProfileImgNumber + " ]"));
    }

    @Test
    @WithMockLoginUser
    void 유저_프로필_업데이트를_진행합니다() throws Exception {
        // given
        Long userId = 1L;
        int testProfileImgNumber = 1;
        String testEmail = "test@test.com";
        String testNickname = "kang";
        String testProviderId = "kakao123123";
        String testHandle = "@qwe123";

        UserProfileUpdateRequest userProfileUpdateRequest = new UserProfileUpdateRequest(testNickname, testProfileImgNumber);


        User user = User.create(testEmail, testProviderId, "test", testHandle, 0, LocalDateTime.now());
        userRepository.save(user);

        // when
        // then
        mockMvc.perform(patch("/api/v1/users/me")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userProfileUpdateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(userId))
                .andExpect(jsonPath("$.profileImgNumber").value(testProfileImgNumber))
                .andExpect(jsonPath("$.nickname").value(testNickname))
                .andExpect(jsonPath("$.providerId").value(testProviderId));
    }


    @Test
    @WithMockLoginUser
    void 유저의_마이페이지를_조회합니다() throws Exception {
        // given
        int testProfileImgNumber = 1;
        String testNickname = "kang";
        String testHandle = "@qwe123";

        User user = User.create("test@test.com", "kakao123123", testNickname, testHandle, testProfileImgNumber, LocalDateTime.now());
        userRepository.save(user);
        User testFollower = User.create("test2@test.com", "google123123", "test", "@ewq321", 3, LocalDateTime.now());
        userRepository.save(testFollower);

        Friend friend = Friend.create(user.getId(), testFollower.getId());
        friendRepository.save(friend);
        Friend friend2 = Friend.create(testFollower.getId(), user.getId());
        friendRepository.save(friend2);

        // when
        // then
        mockMvc.perform(get("/api/v1/users/me/my-page"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nickname").value(testNickname))
                .andExpect(jsonPath("$.profileImgNumber").value(testProfileImgNumber))
                .andExpect(jsonPath("$.handle").value(testHandle))
                .andExpect(jsonPath("$.follower").value(1))
                .andExpect(jsonPath("$.following").value(1));
    }
}