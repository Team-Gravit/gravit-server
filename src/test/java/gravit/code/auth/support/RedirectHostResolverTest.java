package gravit.code.auth.support;

import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import static gravit.code.global.exception.domain.CustomErrorCode.DEST_NOT_VALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RedirectHostResolverTest {

    private static final String PROD_HOST = "https://gravit.inuappcenter.kr";
    private static final String DEV_HOST = "https://dev.gravit.inuappcenter.kr";
    private static final String UNKNOWN_ORIGIN = "https://evil.example.com";

    private final RedirectHostResolver redirectHostResolver = new RedirectHostResolver();

    @Nested
    @DisplayName("웹 redirect 호스트를 판별할 때")
    class Resolve {

        @Test
        void 등록된_Origin이면_Origin을_그대로_돌려준다() {
            // when
            String result = redirectHostResolver.resolve(PROD_HOST, null);

            // then
            assertThat(result).isEqualTo(PROD_HOST);
        }

        @Test
        void 등록된_Origin이면_dest가_달라도_Origin을_따른다() {
            // when
            String result = redirectHostResolver.resolve(PROD_HOST, "dev");

            // then
            assertThat(result).isEqualTo(PROD_HOST);
        }

        @Test
        void Origin이_없으면_dest로_판별한다() {
            // when
            String result = redirectHostResolver.resolve(null, "dev");

            // then
            assertThat(result).isEqualTo(DEV_HOST);
        }

        @Test
        void 등록되지_않은_Origin이면_dest로_판별한다() {
            // when
            String result = redirectHostResolver.resolve(UNKNOWN_ORIGIN, "dev");

            // then
            assertThat(result).isEqualTo(DEV_HOST);
        }

        @Test
        void 끝에_슬래시가_붙은_Origin은_등록된_값과_다르므로_dest로_판별한다() {
            // when
            String result = redirectHostResolver.resolve(PROD_HOST + "/", "dev");

            // then
            assertThat(result).isEqualTo(DEV_HOST);
        }

        @Test
        void Origin과_dest가_모두_없으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> redirectHostResolver.resolve(null, null))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(DEST_NOT_VALID);
        }

        @Test
        void 등록되지_않은_Origin이고_dest도_등록되지_않았으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> redirectHostResolver.resolve(UNKNOWN_ORIGIN, "unknown"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(DEST_NOT_VALID);
        }
    }
}
