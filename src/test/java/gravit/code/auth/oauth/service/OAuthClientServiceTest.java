package gravit.code.auth.oauth.service;

import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.strategy.OAuthResponseFactory;
import gravit.code.auth.service.oauth.OAuthUserInfoService;
import gravit.code.auth.infrastructure.client.OAuthHttpClientAdapter;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.Map;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@SpringBootTest
@ActiveProfiles("test")
class OAuthClientServiceTest {

    @Autowired
    private ClientRegistrationRepository clientRegistrationRepository;

    @Autowired
    private OAuthResponseFactory oAuthResponseFactory;

    @MockitoBean
    private OAuthHttpClientAdapter webClientAdapter;

    @Autowired
    private OAuthUserInfoService oAuthClientService;

    @BeforeEach
    void setUp() {
        when(webClientAdapter.getAccessTokenResponse(any(), any())).thenReturn(Map.of(
                "access_token", "test-access-token"
        ));
        when(webClientAdapter.getUserInfoWithAccessToken(any(), eq("test-access-token")))
                .thenReturn(Map.of("id", "1", "email", "test@test.com"));
    }

    @Test
    void 정상적인_인증_코드와_provider로_사용자_정보를_가져온다() {
        // given
        String authCode = "test-auth-code";
        String provider = "google";
        String dest = "local";

        // when
        OAuthUserInfo result = oAuthClientService.getUserInfo(authCode, provider,dest);

        // then

        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.getEmail()).isEqualTo("test@test.com");
            softly.assertThat(result.getProvider()).isEqualTo(provider);
        });
    }

    @Test
    void 정상적이지_않은_인증_코드는_예외를_던진다(){
        // given
        String authCode = "";
        String provider = "google";
        String dest = "local";

        // when
        // then
        assertThrows(RestApiException.class, ()-> oAuthClientService.getUserInfo(authCode, provider,dest));
    }

    @Test
    void 정상적이지_않은_Provider_는_예외를_던진다(){
        // given
        String authCode = "test-auth-code";
        String provider = "samsung";
        String dest = "local";

        // when
        // then
        assertThrows(RestApiException.class, ()-> oAuthClientService.getUserInfo(authCode, provider,dest));
    }
    
}