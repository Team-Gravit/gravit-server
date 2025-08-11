package gravit.code.domain.user.service;

import gravit.code.domain.recentLearning.service.RecentLearningService;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.user.dto.request.OnboardingRequest;
import gravit.code.domain.user.dto.response.MyPageResponse;
import gravit.code.domain.user.dto.response.UserResponse;
import gravit.code.global.event.OnboardingUserLeagueEvent;
import gravit.code.global.exception.domain.RestApiException;
import org.apache.catalina.core.ApplicationPushBuilder;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @InjectMocks
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RecentLearningService recentLearningService;

    @Mock
    private ApplicationEventPublisher eventPublisher;


    @Test
    void 온보딩_성공_테스트(){
        // given
        Long userId = 1L;
        String testNickname = "kang";
        int testProfilePhotoNumber = 1;
        String testProviderId = "kakao123123";
        User testUser = User.create("test@test.com",testProviderId, "test", "@qwe123",0, LocalDateTime.now());

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        doNothing().when(recentLearningService).initRecentLearning(any(Long.class));
        doNothing().when(eventPublisher).publishEvent(any(OnboardingUserLeagueEvent.class));


        // when
        UserResponse result = userService.onboarding(userId, request);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.providerId()).isEqualTo(testUser.getProviderId());
            softly.assertThat(result.nickname()).isEqualTo(testNickname);
            softly.assertThat(result.profileImgNumber()).isEqualTo(testProfilePhotoNumber);
            softly.assertThat(testUser.isOnboarded()).isEqualTo(true);
        });
    }

    @Test
    void 온보딩시_닉네임이_8자_이상이면_예외를_던집니다(){
        // given
        Long userId = 1L;
        String testNickname = "kangkangkang";
        int testProfilePhotoNumber = 1;
        String testProviderId = "kakao123123";
        User testUser = User.create("test@test.com",testProviderId, "test", "@qwe123",0, LocalDateTime.now());

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
    }


    @Test
    void 온보딩시_닉네임이_2자_이하면_예외를_던집니다(){
        // given
        Long userId = 1L;
        String testNickname = "k";
        int testProfilePhotoNumber = 1;
        String testProviderId = "kakao123123";
        User testUser = User.create("test@test.com",testProviderId, "test", "@qwe123",0, LocalDateTime.now());

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
    }

    @Test
    void 온보딩시_프로필_이미지_번호가_1보다_작으면_예외를_던집니다(){
        // given
        Long userId = 1L;
        String testNickname = "kang";
        int testProfilePhotoNumber = 0;
        String testProviderId = "kakao123123";
        User testUser = User.create("test@test.com",testProviderId, "test", "@qwe123",0, LocalDateTime.now());

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
    }

    @Test
    void 온보딩시_프로필_이미지_번호가_10보다_크면_예외를_던집니다(){
        // given
        Long userId = 1L;
        String testNickname = "kang";
        int testProfilePhotoNumber = 11;
        String testProviderId = "kakao123123";
        User testUser = User.create("test@test.com",testProviderId, "test", "@qwe123",0, LocalDateTime.now());

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
    }

    @Test
    void 유저가_존재하지_않으면_예외를_던집니다(){
        // given
        Long userId = 1L;
        String testNickname = "kang";
        int testProfilePhotoNumber = 1;

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
    }

    @Test
    void 이미_온보딩을_한_유저라면_예외를_던집니다(){
        // given
        Long userId = 1L;
        String testNickname = "kang";
        int testProfilePhotoNumber = 1;
        String testProviderId = "kakao123123";
        User testUser = User.create("test@test.com",testProviderId, "test", "@qwe123",0, LocalDateTime.now());
        testUser.checkOnboarded();

        OnboardingRequest request = new OnboardingRequest(testNickname, testProfilePhotoNumber);
        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.onboarding(userId, request));
    }

    @Test
    void 유저_아이디로_유저를_조회합니다(){
        // given
        Long userId = 1L;
        String testEmail = "test@test.com";
        String testNickname = "kang";
        String testHandle = "@qwe123";
        int testProfilePhotoNumber = 1;
        String testProviderId = "kakao123123";
        User testUser = User.create(testEmail, testProviderId, testNickname, testHandle, testProfilePhotoNumber, LocalDateTime.now());

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // when
        UserResponse result = userService.findById(userId);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.providerId()).isEqualTo(testUser.getProviderId());
            softly.assertThat(result.nickname()).isEqualTo(testNickname);
            softly.assertThat(result.profileImgNumber()).isEqualTo(testProfilePhotoNumber);
        });
    }

    @Test
    void 유저_아이디로_유저_마이페이지를_조회합니다(){
        // given
        Long userId = 1L;
        int testProfilePhotoNumber = 1;
        String testNickname = "kang";
        String testHandle = "@qwe123";
        int testFollowerCount = 1;
        int testFollowingCount = 1;

        MyPageResponse myPageResponse = new MyPageResponse(testNickname, testProfilePhotoNumber, testHandle, testFollowerCount, testFollowingCount);
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
        Long userId = 1L;

        when(userRepository.findMyPageByUserId(userId)).thenReturn(Optional.empty());

        // when
        // then
        assertThrows(RestApiException.class, ()-> userService.getMyPage(userId));
    }
}