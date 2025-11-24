//package gravit.code.auth.oauth.processor;
//
//import gravit.code.auth.domain.AccessToken;
//import gravit.code.auth.domain.RefreshToken;
//import gravit.code.auth.dto.oauth.OAuthUserInfo;
//import gravit.code.auth.dto.response.LoginResponse;
//import gravit.code.auth.policy.AdminPromotionPolicy;
//import gravit.code.auth.service.AuthTokenProvider;
//import gravit.code.auth.service.oauth.OAuthLoginProcessor;
//import gravit.code.user.domain.HandleGenerator;
//import gravit.code.user.domain.Role;
//import gravit.code.user.domain.User;
//import gravit.code.user.domain.UserRepository;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import java.util.Optional;
//
//import static org.assertj.core.api.SoftAssertions.assertSoftly;
//import static org.mockito.Mockito.*;
//
//@ExtendWith(MockitoExtension.class)
//class OAuthLoginProcessorTest {
//
//    @Mock
//    private UserRepository userRepository;
//
//    @Mock
//    private AuthTokenProvider authTokenProvider;
//
//    @Mock
//    private HandleGenerator handleGenerator;
//
//    @InjectMocks
//    private OAuthLoginProcessor oAuthLoginProcessor;
//
//    @Mock
//    private OAuthUserInfo oAuthUserInfo;
//
//    @Mock
//    private AdminPromotionPolicy adminRoleDecider;
//
//
//    private final String testOAuthEmail = "test@test.com";
//    private final String testOAuthProvider = "kakao";
//    private final String testOAuthProviderId = "123123";
//    private final int testProfileId = 1;
//    private final String testAccessToken = "this-is-a-test-access-token";
//    private final String testRefreshToken = "this-is-a-test-refresh-token";
//
//
//    @Test
//    void 기존_유저가_있으면_회원가입하지_않고_로그인을_진행한다() {
//        // given
//        String makeProviderId = testOAuthProvider + " " + testOAuthProviderId;
//        String testNickname = "kang";
//        String testEmail = "test@test.com";
//        String testHandle = "@qwe123";
//
//        User existingUser = User.create(testEmail, makeProviderId, testNickname, testHandle, testProfileId, Role.USER);
//        when(oAuthUserInfo.getProvider()).thenReturn(testOAuthProvider);
//        when(oAuthUserInfo.getProviderId()).thenReturn(testOAuthProviderId);
//
//        when(userRepository.findByProviderId(makeProviderId))
//                .thenReturn(Optional.of(existingUser));
//        when(authTokenProvider.generateAccessToken(existingUser))
//                .thenReturn(new AccessToken(testAccessToken));
//        when(authTokenProvider.generateRefreshToken(existingUser))
//                .thenReturn(new RefreshToken(testRefreshToken));
//
//        // when
//        LoginResponse result = oAuthLoginProcessor.process(oAuthUserInfo);
//
//        // then
//        assertSoftly(softly -> {
//            softly.assertThat(result.accessToken()).isEqualTo(testAccessToken);
//            softly.assertThat(result.refreshToken()).isEqualTo(testRefreshToken);
//            softly.assertThat(result.isOnboarded()).isEqualTo(false);
//        });
//    }
//
//    @Test
//    void 기존_유저가_없으면_회원가입을_진행한다() {
//        // given
//        String makeProviderId = testOAuthProvider + " " + testOAuthProviderId;
//        String testNickname = "kang";
//        String testHandle = "@qwe123";
//
//        User newUser = User.create(testOAuthEmail, makeProviderId, testNickname, testHandle, testProfileId, Role.USER);
//        when(oAuthUserInfo.getProvider()).thenReturn(testOAuthProvider);
//        when(oAuthUserInfo.getProviderId()).thenReturn(testOAuthProviderId);
//
//        when(userRepository.findByProviderId(makeProviderId))
//                .thenReturn(Optional.empty());
//        when(authTokenProvider.generateAccessToken(any(User.class)))
//                .thenReturn(new AccessToken(testAccessToken));
//        when(authTokenProvider.generateRefreshToken(any(User.class)))
//                .thenReturn(new RefreshToken(testRefreshToken));
//        when(handleGenerator.generateUniqueHandle()).thenReturn(testHandle);
//        when(adminRoleDecider.initRole(oAuthUserInfo.getEmail())).thenReturn(Role.USER);
//        doNothing().when(userRepository).save(any(User.class));
//
//        // when
//        LoginResponse result = oAuthLoginProcessor.process(oAuthUserInfo);
//
//        // then
//        assertSoftly(softly -> {
//            softly.assertThat(result.accessToken()).isEqualTo(testAccessToken);
//            softly.assertThat(result.refreshToken()).isEqualTo(testRefreshToken);
//            softly.assertThat(result.isOnboarded()).isEqualTo(false);
//        });
//    }
//
//}