package gravit.code.auth.oauth.service;

import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class OAuthLoginUrlServiceTest {

    @Autowired
    private OAuthLoginUrlService oAuthLoginUrlService;

    @Test
    void naver_provider_를_이용해서_login_url을_생성합니다() {
        // given
        String provider = "naver";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("test-redirect-uri")).isTrue();
        });
    }

    @Test
    void 소문자_naver_provider가_아니여도_로그인_url을_생성할_수_있습니다() {
        // given
        String provider = "NaVer";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("test-redirect-uri")).isTrue();
        });
    }

    @Test
    void google_provider_를_이용해서_login_url을_생성합니다() {
        // given
        String provider = "google";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("test-redirect-uri")).isTrue();
        });
    }

    @Test
    void 소문자_google_provider가_아니여도_로그인_url을_생성할_수_있습니다() {
        // given
        String provider = "GoogLe";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("test-redirect-uri")).isTrue();
        });
    }

    @Test
    void kakao_provider_를_이용해서_login_url을_생성합니다() {
        // given
        String provider = "kakao";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("test-redirect-uri")).isTrue();
        });
    }

    @Test
    void 소문자_kakao_provider가_아니여도_로그인_url을_생성할_수_있습니다() {
        // given
        String provider = "KAKAo";

        // when
        String result = oAuthLoginUrlService.generateLoginUrl(provider);

        // then
        assertSoftly(softly -> {
            softly.assertThat(result).isNotNull();
            softly.assertThat(result.contains("test-client-id")).isTrue();
            softly.assertThat(result.contains("test-redirect-uri")).isTrue();
        });
    }

    @Test
    void 올바르지_않은_provider_로_요청하면_예외를_던집니다() {
        // given
        String provider = "samsung";

        // when
        // then
        assertThrows(RestApiException.class, ()-> oAuthLoginUrlService.generateLoginUrl(provider));
    }
}