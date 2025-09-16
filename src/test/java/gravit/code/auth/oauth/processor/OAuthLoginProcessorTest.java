package gravit.code.auth.oauth.processor;

import gravit.code.auth.jwt.JwtProvider;
import gravit.code.auth.oauth.bootstrap.AdminRoleDecider;
import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.util.HandleGenerator;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OAuthLoginProcessorTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtProvider jwtProvider;

    @Mock
    private HandleGenerator handleGenerator;

    @InjectMocks
    private OAuthLoginProcessor oAuthLoginProcessor;

    @Mock
    private OAuthUserInfo oAuthUserInfo;

    @Mock
    private AdminRoleDecider adminRoleDecider;


    private final String testOAuthEmail = "test@test.com";
    private final String testOAuthProvider = "kakao";
    private final String testOAuthProviderId = "123123";
    private final int testProfileId = 1;
    private final String testToken = "this-is-a-test-access-token";

    @Test
    void 기존_유저가_있으면_회원가입하지_않고_로그인을_진행한다() {
        // given
        String makeProviderId = testOAuthProvider + " " + testOAuthProviderId;
        String testNickname = "kang";
        String testEmail = "test@test.com";
        String testHandle = "@qwe123";

        User existingUser = User.create(testEmail, makeProviderId, testNickname, testHandle, testProfileId, Role.USER);
        when(oAuthUserInfo.getProvider()).thenReturn(testOAuthProvider);
        when(oAuthUserInfo.getProviderId()).thenReturn(testOAuthProviderId);

        when(userRepository.findByProviderId(makeProviderId))
                .thenReturn(Optional.of(existingUser));
        when(jwtProvider.createAccessToken(existingUser.getId()))
                .thenReturn(testToken);

        // when
        LoginResponse result = oAuthLoginProcessor.process(oAuthUserInfo);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.accessToken()).isEqualTo(testToken);
            softly.assertThat(result.isOnboarded()).isEqualTo(false);
        });
    }

    @Test
    void 기존_유저가_없으면_회원가입을_진행한다() {
        // given
        String makeProviderId = testOAuthProvider + " " + testOAuthProviderId;
        String testNickname = "kang";
        String testHandle = "@qwe123";

        User newUser = User.create(testOAuthEmail, makeProviderId, testNickname, testHandle, testProfileId, Role.USER);
        when(oAuthUserInfo.getProvider()).thenReturn(testOAuthProvider);
        when(oAuthUserInfo.getProviderId()).thenReturn(testOAuthProviderId);

        when(userRepository.findByProviderId(makeProviderId))
                .thenReturn(Optional.empty());
        when(jwtProvider.createAccessToken(newUser.getId()))
                .thenReturn(testToken);
        when(handleGenerator.generateUniqueHandle()).thenReturn(testHandle);
        doNothing().when(userRepository).save(any(User.class));

        // when
        LoginResponse result = oAuthLoginProcessor.process(oAuthUserInfo);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result.accessToken()).isEqualTo(testToken);
            softly.assertThat(result.isOnboarded()).isEqualTo(false);
        });
    }

}