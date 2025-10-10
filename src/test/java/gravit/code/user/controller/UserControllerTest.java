package gravit.code.user.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.GravitApplication;
import gravit.code.common.auth.WithMockLoginUser;
import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.fixture.UserFixtureBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = GravitApplication.class)
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
    private UserRepository userRepository;

    @Autowired
    private FriendRepository friendRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    
    @DisplayName("유저/마이페이지 조회 할 때")
    @Nested
    class UserAndMyPgeSelect{
        @Test
        @WithMockLoginUser
        void 유저ID로_유저를_조회합니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(get("/api/v1/users"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.userId").value(testUser.getId()))
                    .andExpect(jsonPath("$.profileImgNumber").value(testUser.getProfileImgNumber()))
                    .andExpect(jsonPath("$.nickname").value(testUser.getNickname()))
                    .andExpect(jsonPath("$.providerId").value(testUser.getProviderId()));
        }

        @Test
        @WithMockLoginUser
        void 없는_유저를_유저ID로_조회하면_예외가_리턴됩니다() throws Exception {
            // given
            // when
            // then
            mockMvc.perform(get("/api/v1/users"))
                    .andExpect(status().isNotFound())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("USER_4041"))
                    .andExpect(jsonPath("$.message").value("존재하지 않는 유저입니다."));
        }

        @Test
        @WithMockLoginUser
        void 유저의_마이페이지를_조회합니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().handle("test1").build();
            userRepository.save(testUser);
            User testFollower = UserFixtureBuilder.builder().handle("test2").build();
            userRepository.save(testFollower);

            Friend friend = Friend.create(testUser.getId(), testFollower.getId());
            friendRepository.save(friend);

            Friend friend2 = Friend.create(testFollower.getId(), testUser.getId());
            friendRepository.save(friend2);

            // when
            // then
            mockMvc.perform(get("/api/v1/users/my-page"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.nickname").value(testUser.getNickname()))
                    .andExpect(jsonPath("$.profileImgNumber").value(testUser.getProfileImgNumber()))
                    .andExpect(jsonPath("$.handle").value(testUser.getHandle()))
                    .andExpect(jsonPath("$.follower").value(1))
                    .andExpect(jsonPath("$.following").value(1));
        }

        @Test
        @WithMockLoginUser
        void 없는_유저의_마이페이지를_조회하면_예외를_리턴합니다() throws Exception {
            // given
            // when
            // then
            mockMvc.perform(get("/api/v1/users/my-page"))
                    .andExpect(status().isNotFound())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("USER_PAGE_4041"))
                    .andExpect(jsonPath("$.message").value("유저 페이지가 존재하지 않습니다."));
        }
    }

    @DisplayName("온보딩 관련")
    @Nested
    class Onboarding{
        @Test
        @WithMockLoginUser
        void 회원가입_이후_온보딩을_진행합니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            String onboardingNickname = "kang";
            int onboardingProfileImgNumber = 1;
            OnboardingRequest onboardingRequest = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(post("/api/v1/users/onboarding")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(onboardingRequest)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.userId").value(testUser.getId()))
                    .andExpect(jsonPath("$.nickname").value(onboardingNickname))
                    .andExpect(jsonPath("$.profileImgNumber").value(onboardingProfileImgNumber))
                    .andExpect(jsonPath("$.providerId").value(testUser.getProviderId()));
        }

        @Test
        @WithMockLoginUser
        void 닉네임_길이가_2보다_작으면_예외를_던집니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            String onboardingNickname = "k";
            int onboardingProfileImgNumber = 1;
            OnboardingRequest onboardingRequest = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(post("/api/v1/users/onboarding")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(onboardingRequest)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ nickname ][ 닉네임은 2자 이상 8자 이하이어야 합니다. ][ " + onboardingNickname + " ]"));
        }

        @Test
        @WithMockLoginUser
        void 닉네임이_8자보다_길_경우_예외를_던집니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            String onboardingNickname = "kangkangkang";
            int onboardingProfileImgNumber = 1;
            OnboardingRequest onboardingRequest = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(post("/api/v1/users/onboarding")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(onboardingRequest)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ nickname ][ 닉네임은 2자 이상 8자 이하이어야 합니다. ][ " + onboardingNickname + " ]"));
        }

        @Test
        @WithMockLoginUser
        void 프로필_이미지_아이디가_10보다_크면_예외를_던집니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            String onboardingNickname = "kang";
            int onboardingProfileImgNumber = 11;
            OnboardingRequest onboardingRequest = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(post("/api/v1/users/onboarding")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(onboardingRequest)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ profilePhotoNumber ][ 프로필 사진 번호는 10 이하여야 합니다. ][ " + onboardingProfileImgNumber + " ]"));
        }

        @Test
        @WithMockLoginUser
        void 프로필_이미지_아이디가_1보다_작으면_예외를_던집니다() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            String onboardingNickname = "kang";
            int onboardingProfileImgNumber = 0;
            OnboardingRequest onboardingRequest = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(post("/api/v1/users/onboarding")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(onboardingRequest)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ profilePhotoNumber ][ 프로필 사진 번호는 1 이상이어야 합니다. ][ " + onboardingProfileImgNumber + " ]"));
        }
    }

    @DisplayName("유저 프로필 업데이트 관련")
    @Nested
    class UserProfileUpdate{
        @Test
        @WithMockLoginUser
        void 유저_프로필_업데이트() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            String onboardingNickname = "kang";
            int onboardingProfileImgNumber = 1;

            UserProfileUpdateRequest userProfileUpdateRequest = new UserProfileUpdateRequest(onboardingNickname, onboardingProfileImgNumber);

            userRepository.save(testUser);

            // when
            // then
            mockMvc.perform(patch("/api/v1/users")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(userProfileUpdateRequest)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.userId").value(testUser.getId()))
                    .andExpect(jsonPath("$.nickname").value(onboardingNickname))
                    .andExpect(jsonPath("$.profileImgNumber").value(onboardingProfileImgNumber))
                    .andExpect(jsonPath("$.providerId").value(testUser.getProviderId()));
        }

        @Test
        @WithMockLoginUser
        void 닉네임_길이가_2보다_작으면_예외() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            userRepository.save(testUser);
            String updateNickname = "k";
            int updateProfileImgNumber = 1;
            var req = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            // when & then (검증 에러는 보통 리스트 응답)
            mockMvc.perform(patch("/api/v1/users")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ nickname ][ 닉네임은 2자 이상 8자 이하이어야 합니다. ][ " + updateNickname + " ]"));
        }

        @Test
        @WithMockLoginUser
        void 닉네임이_8자보다_길면_예외() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            userRepository.save(testUser);
            String updateNickname = "testtesttest";
            int updateProfileImgNumber = 1;
            UserProfileUpdateRequest req = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            // when & then
            mockMvc.perform(patch("/api/v1/users")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ nickname ][ 닉네임은 2자 이상 8자 이하이어야 합니다. ][ " + updateNickname + " ]"));
        }

        @Test
        @WithMockLoginUser
        void 프로필이미지_아이디가_10보다_크면_예외() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            userRepository.save(testUser);
            String updateNickname = "testtest";
            int updateProfileImgNumber = 11;
            UserProfileUpdateRequest req = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            // when & then
            mockMvc.perform(patch("/api/v1/users")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ profilePhotoNumber ][ 프로필 사진 번호는 10 이하여야 합니다. ][ " + updateProfileImgNumber + " ]"));
        }

        @Test
        @WithMockLoginUser
        void 프로필이미지_아이디가_1보다_작으면_예외() throws Exception {
            // given
            User testUser = UserFixtureBuilder.builder().build();
            userRepository.save(testUser);
            String updateNickname = "test";
            int updateProfileImgNumber = 0;

            UserProfileUpdateRequest req = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            // when & then
            mockMvc.perform(patch("/api/v1/users")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(req)))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.error").value("GLOBAL_4001"))
                    .andExpect(jsonPath("$.message[0]").value("[ profilePhotoNumber ][ 프로필 사진 번호는 1 이상이어야 합니다. ][ " + updateProfileImgNumber + " ]"));
        }
    }

}