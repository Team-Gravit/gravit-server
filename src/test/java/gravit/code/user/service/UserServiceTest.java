package gravit.code.user.service;

import gravit.code.global.event.OnboardingUserLeagueEvent;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.mainPage.dto.MainPageSummary;
import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.dto.MissionSummary;
import gravit.code.mission.service.MissionService;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.user.fixture.UserFixtureBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.util.Optional;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @InjectMocks
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @Mock
    private MissionService missionService;


    @DisplayName("온보딩 할 때")
    @Nested
    class Onboarding{

        @Test
        void 온보딩_성공_테스트(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);

            String onboardingNickname = "test";
            int onboardingProfileImgNumber = 1;

            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
            doNothing().when(eventPublisher).publishEvent(any(CreateLearningEvent.class));
            doNothing().when(eventPublisher).publishEvent(any(OnboardingUserLeagueEvent.class));

            // when
            UserResponse result = userService.onboarding(testUser.getId(), request);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userId()).isEqualTo(testUser.getId());
                softly.assertThat(result.providerId()).isEqualTo(testUser.getProviderId());
                softly.assertThat(result.nickname()).isEqualTo(onboardingNickname);
                softly.assertThat(result.profileImgNumber()).isEqualTo(onboardingProfileImgNumber);
                softly.assertThat(testUser.isOnboarded()).isEqualTo(true);
            });
        }

        @Test
        void 온보딩시_닉네임이_8자_이상이면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String onboardingNickname = "testtesttest";
            int onboardingProfileImgNumber = 1;

            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
        }


        @Test
        void 온보딩시_닉네임이_2자_이하면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String onboardingNickname = "k";
            int onboardingProfileImgNumber = 1;

            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
        }

        @Test
        void 온보딩시_프로필_이미지_번호가_1보다_작으면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);

            String onboardingNickname = "test";
            int onboardingProfileImgNumber = 0;

            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
        }

        @Test
        void 온보딩시_프로필_이미지_번호가_10보다_크면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String onboardingNickname = "kang";
            int onboardingProfileImgNumber = 11;

            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
        }

        @Test
        void 이미_온보딩을_한_유저라면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder()
                    .onboarded()
                    .buildWithId(userId);
            String onboardingNickname = "kang";
            int onboardingProfileImgNumber = 11;
            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
        }

        @Test
        void 온보딩시_유저가_존재하지_않으면_예외를_던집니다(){
            // given
            long userId = 1L;
            String onboardingNickname = "test";
            int onboardingProfileImgNumber = 1;

            OnboardingRequest request = new OnboardingRequest(onboardingNickname, onboardingProfileImgNumber);
            when(userRepository.findById(userId)).thenReturn(Optional.empty());

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
        }
    }

    @DisplayName("유저/마이페이지 조회 관련")
    @Nested
    class UserAndMyPageSelect{

        @Test
        void 유저_아이디로_유저를_조회합니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder()
                    .onboarded()
                    .buildWithId(userId);
            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            UserResponse result = userService.findById(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userId()).isEqualTo(testUser.getId());
                softly.assertThat(result.providerId()).isEqualTo(testUser.getProviderId());
                softly.assertThat(result.nickname()).isEqualTo(testUser.getNickname());
                softly.assertThat(result.profileImgNumber()).isEqualTo(testUser.getProfileImgNumber());
            });
        }

        @Test
        void 유저_조회_시_유저가_존재하지_않으면_에러를_리턴합니다(){
            long userId = 1L;

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.findById(userId));
        }

        @Test
        void 유저_아이디로_유저_마이페이지를_조회합니다(){
            // given
            long userId = 1L;
            int testProfilePhotoNumber = 1;
            String testNickname = "kang";
            String testHandle = "@qwe123";
            int testFollowerCount = 1;
            int testFollowingCount = 1;

            MyPageResponse myPageResponse = new MyPageResponse(
                    testNickname,
                    testProfilePhotoNumber,
                    testHandle,
                    testFollowerCount,
                    testFollowingCount
            );

            when(userRepository.findMyPageByUserId(userId)).thenReturn(Optional.of(myPageResponse));

            // when
            MyPageResponse result = userService.getMyPage(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.handle()).isEqualTo(testHandle);
                softly.assertThat(result.nickname()).isEqualTo(testNickname);
                softly.assertThat(result.profileImgNumber()).isEqualTo(testProfilePhotoNumber);
                softly.assertThat(result.follower()).isEqualTo(testFollowerCount);
                softly.assertThat(result.following()).isEqualTo(testFollowingCount);
            });
        }

        @Test
        void 유저의_마이페이지가_존재하지_않다면_예외를_던집니다(){
            // given
            long userId = 1L;

            when(userRepository.findMyPageByUserId(userId)).thenReturn(Optional.empty());

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.getMyPage(userId));
        }
    }

    @DisplayName("유저 프로필 수정 관련")
    @Nested
    class UserProfileUpdate{

        @Test
        void 유저_프로필_업데이트_성공_테스트(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String updateNickname = "newNick";
            int updateProfileImgNumber = 5;

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
            UserProfileUpdateRequest request = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            // when
            UserResponse result = userService.updateUserProfile(userId, request);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.userId()).isEqualTo(testUser.getId());
                softly.assertThat(result.providerId()).isEqualTo(testUser.getProviderId());
                softly.assertThat(result.nickname()).isEqualTo(updateNickname);
                softly.assertThat(result.profileImgNumber()).isEqualTo(updateProfileImgNumber);
            });
        }

        @Test
        void 유저_프로필_업데이트_시_닉네임이_8자_이상이면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String updateNickname = "testtesttest";
            int updateProfileImgNumber = 1;

            UserProfileUpdateRequest request = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.updateUserProfile(userId, request));
        }


        @Test
        void 유저_프로필_업데이트_시_닉네임이_2자_이하면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String updateNickname = "k";
            int updateProfileImgNumber = 1;

            UserProfileUpdateRequest request = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.updateUserProfile(userId, request));
        }

        @Test
        void 유저_프로필_업데이트_시_프로필_이미지_번호가_1보다_작으면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String updateNickname = "test";
            int updateProfileImgNumber = 0;

            UserProfileUpdateRequest request = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);
            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.updateUserProfile(userId, request));
        }

        @Test
        void 온보딩시_프로필_이미지_번호가_10보다_크면_예외를_던집니다(){
            // given
            long userId = 1L;
            User testUser = UserFixtureBuilder.builder().buildWithId(userId);
            String updateNickname = "test";
            int updateProfileImgNumber = 11;

            UserProfileUpdateRequest request = new UserProfileUpdateRequest(updateNickname, updateProfileImgNumber);

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            // then
            assertThrows(RestApiException.class, ()-> userService.updateUserProfile(userId, request));
        }
    }
    
    @DisplayName("학습 후 제공되는 xp 를 적용한 유저 레벨 증가 관련")
    @Nested
    class UserLevelAndXpUpdate{
        @Test
        void 레벨_변동_없음(){
            // given
            long userId = 1L;
            int preLevel = 1;
            int preXp = 0;
            User testUser = UserFixtureBuilder.builder()
                    .onboarded()
                    .buildWithLevelAndId(
                            userId,
                            new UserLevel(preLevel, preXp)
                    );

            int xp = 10;
            int accuracy = 50;

            int currentLevel = preLevel;
            int nextLevel = currentLevel + 1;

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            UserLevelResponse result = userService.updateUserLevelAndXp(userId, xp, accuracy);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.currentLevel()).isEqualTo(currentLevel);
                softly.assertThat(result.nextLevel()).isEqualTo(nextLevel);
            });
        }

        @Test
        void 레벨이_증가(){
            // given
            long userId = 1L;
            int preLevel = 1;
            int preXp = 99;
            User testUser = UserFixtureBuilder.builder()
                    .onboarded()
                    .buildWithLevelAndId(
                            userId,
                            new UserLevel(preLevel, preXp)
                    );

            int xp = 20;
            int accuracy = 50;

            int currentLevel = preLevel + 1;
            int nextLevel = currentLevel + 1;

            when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

            // when
            UserLevelResponse result = userService.updateUserLevelAndXp(userId, xp, accuracy);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.currentLevel()).isEqualTo(currentLevel);
                softly.assertThat(result.nextLevel()).isEqualTo(nextLevel);
            });
        }
    }

    @DisplayName("유저의 메인 페이지 관련")
    @Nested
    class UserMainPage{
        @Test
        void 유저_Id_기반으로_유저의_메인_페이지를_조회합니다(){

            // given
            long userId = 1L;
            String nickname = "test";
            String leagueName = "testLeague";
            int xp = 0;
            int level = 1;
            int planetConquestRate = 15;
            int consecutiveDays = 10;
            long chapterId = 1L;
            String chapterName = "testChater";
            String chapterDescription = "testDescription";
            long totalUnits = 10;
            long completedUnits = 10;

            MainPageSummary mainPageSummary = new MainPageSummary(
                    nickname,
                    leagueName,
                    xp,
                    level,
                    planetConquestRate,
                    consecutiveDays,
                    chapterId,
                    chapterName,
                    chapterDescription,
                    totalUnits,
                    completedUnits
            );

            MissionType missionType = MissionType.COMPLETE_LESSON_ONE;
            boolean isMissionCompleted = false;

            MissionSummary missionSummary = new MissionSummary(missionType, isMissionCompleted);

            when(userRepository.findMainPageByUserId(userId)).thenReturn(mainPageSummary);
            when(missionService.getMissionSummary(userId)).thenReturn(missionSummary);

            // when
            MainPageResponse result = userService.getMainPage(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.nickname()).isEqualTo(nickname);
                softly.assertThat(result.leagueName()).isEqualTo(leagueName);
                softly.assertThat(result.xp()).isEqualTo(xp);
                softly.assertThat(result.level()).isEqualTo(level);
                softly.assertThat(result.planetConquestRate()).isEqualTo(planetConquestRate);
                softly.assertThat(result.consecutiveDays()).isEqualTo(consecutiveDays);
                softly.assertThat(result.chapterId()).isEqualTo(chapterId);
                softly.assertThat(result.chapterName()).isEqualTo(chapterName);
                softly.assertThat(result.chapterDescription()).isEqualTo(chapterDescription);
                softly.assertThat(result.totalUnits()).isEqualTo(totalUnits);
                softly.assertThat(result.completedUnits()).isEqualTo(completedUnits);
                softly.assertThat(result.missionName()).isEqualTo(missionType.getDescription());
                softly.assertThat(result.awardXp()).isEqualTo(missionType.getAwardXp());
                softly.assertThat(result.isCompleted()).isEqualTo(isMissionCompleted);
            });
        }

    }

}