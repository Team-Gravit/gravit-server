package gravit.code.auth.oauth.service;

import gravit.code.auth.service.oauth.OAuthLoginUrlService;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.junit.jupiter.api.Assertions.assertThrows;

@TCSpringBootTest
@ActiveProfiles("test")
class OAuthLoginUrlServiceTest {

    @Autowired
    private OAuthLoginUrlService oAuthLoginUrlService;

    @Test
    void naver_provider_를_이용해서_login_url을_생성합니다() {
        // given
        String provider = "naver";
        String dest = "local";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider,dest);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("http://localhost:5173/login/oauth2/code/naver")).isTrue();
        });
    }

    @Test
    void 소문자_naver_provider가_아니여도_로그인_url을_생성할_수_있습니다() {
        // given
        String provider = "NaVer";
        String dest = "local";


        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider,dest);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("http://localhost:5173/login/oauth2/code/naver")).isTrue();
        });
    }

    @Test
    void google_provider_를_이용해서_login_url을_생성합니다() {
        // given
        String provider = "google";
        String dest = "local";


        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider,dest);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("http://localhost:5173/login/oauth2/code/google")).isTrue();
        });
    }

    @Test
    void 소문자_google_provider가_아니여도_로그인_url을_생성할_수_있습니다() {
        // given
        String provider = "GoogLe";
        String dest = "local";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider,dest);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("http://localhost:5173/login/oauth2/code/google")).isTrue();
        });
    }

    @Test
    void kakao_provider_를_이용해서_login_url을_생성합니다() {
        // given
        String provider = "kakao";
        String dest = "local";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider,dest);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("http://localhost:5173/login/oauth2/code/kakao")).isTrue();
        });
    }

    @Test
    void 소문자_kakao_provider가_아니여도_로그인_url을_생성할_수_있습니다() {
        // given
        String provider = "KAKAo";
        String dest = "local";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider,dest);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("http://localhost:5173/login/oauth2/code/kakao")).isTrue();
        });
    }

    @Test
    void 올바르지_않은_provider_로_요청하면_예외를_던집니다() {
        // given
        String provider = "samsung";
        String dest = "local";

        // when
        // then
        assertThrows(RestApiException.class, ()-> oAuthLoginUrlService.generateLoginUrl(provider,dest));
    }
}