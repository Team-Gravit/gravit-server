package gravit.code.auth.infrastructure.config;

import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.context.properties.bind.validation.BindValidationException;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Configuration;

import static gravit.code.global.exception.domain.CustomErrorCode.PROVIDER_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class OAuthIosPropsTest {

    private static final String GOOGLE_ISSUER = "oauth.ios.google.issuer=https://accounts.google.com";
    private static final String GOOGLE_CLIENT_ID = "oauth.ios.google.client-id=ios-google-client-id";
    private static final String KAKAO_ISSUER = "oauth.ios.kakao.issuer=https://kauth.kakao.com";
    private static final String KAKAO_CLIENT_ID = "oauth.ios.kakao.client-id=ios-kakao-client-id";

    private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
            .withUserConfiguration(PropsConfig.class);

    @Configuration
    @EnableConfigurationProperties(OAuthIosProps.class)
    static class PropsConfig {
    }

    @Nested
    @DisplayName("서버가 기동할 때")
    class Binding {

        @Test
        void 모든_값이_있으면_iOS_검증_설정이_만들어진다() {
            contextRunner
                    .withPropertyValues(GOOGLE_ISSUER, GOOGLE_CLIENT_ID, KAKAO_ISSUER, KAKAO_CLIENT_ID)
                    .run(context -> {
                        OAuthIosProps props = context.getBean(OAuthIosProps.class);

                        assertSoftly(softly -> {
                            softly.assertThat(props.getClientId("google")).isEqualTo("ios-google-client-id");
                            softly.assertThat(props.getClientId("kakao")).isEqualTo("ios-kakao-client-id");
                            softly.assertThat(props.getIssuer("google")).isEqualTo("https://accounts.google.com");
                            softly.assertThat(props.getIssuer("kakao")).isEqualTo("https://kauth.kakao.com");
                        });
                    });
        }

        @Test
        void 구글_client_id가_비어_있으면_기동에_실패한다() {
            contextRunner
                    .withPropertyValues(GOOGLE_ISSUER, "oauth.ios.google.client-id=", KAKAO_ISSUER, KAKAO_CLIENT_ID)
                    .run(context -> assertThat(context)
                            .hasFailed()
                            .getFailure()
                            .hasRootCauseInstanceOf(BindValidationException.class));
        }

        @Test
        void 카카오_client_id가_없으면_기동에_실패한다() {
            contextRunner
                    .withPropertyValues(GOOGLE_ISSUER, GOOGLE_CLIENT_ID, KAKAO_ISSUER)
                    .run(context -> assertThat(context)
                            .hasFailed()
                            .getFailure()
                            .hasRootCauseInstanceOf(BindValidationException.class));
        }

        @Test
        void oauth_ios_블록이_없으면_기동에_실패한다() {
            contextRunner
                    .run(context -> assertThat(context)
                            .hasFailed()
                            .getFailure()
                            .hasRootCauseInstanceOf(BindValidationException.class));
        }
    }

    @Nested
    @DisplayName("제공자별 검증 값을 조회할 때")
    class Lookup {

        @Test
        void 대소문자와_상관없이_제공자를_찾는다() {
            contextRunner
                    .withPropertyValues(GOOGLE_ISSUER, GOOGLE_CLIENT_ID, KAKAO_ISSUER, KAKAO_CLIENT_ID)
                    .run(context -> assertThat(context.getBean(OAuthIosProps.class).getClientId("GOOGLE"))
                            .isEqualTo("ios-google-client-id"));
        }

        @Test
        void IdToken_방식을_지원하지_않는_제공자면_예외를_던진다() {
            contextRunner
                    .withPropertyValues(GOOGLE_ISSUER, GOOGLE_CLIENT_ID, KAKAO_ISSUER, KAKAO_CLIENT_ID)
                    .run(context -> {
                        OAuthIosProps props = context.getBean(OAuthIosProps.class);

                        assertThatThrownBy(() -> props.getClientId("naver"))
                                .isInstanceOf(RestApiException.class)
                                .extracting(e -> ((RestApiException) e).getErrorCode())
                                .isEqualTo(PROVIDER_INVALID);
                    });
        }
    }
}
