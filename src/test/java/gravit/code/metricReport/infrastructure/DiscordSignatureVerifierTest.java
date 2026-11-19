package gravit.code.metricReport.infrastructure;

import gravit.code.metricReport.config.DiscordProps;
import gravit.code.metricReport.fixture.DiscordTestKey;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class DiscordSignatureVerifierTest {

    private static final String TIMESTAMP = "1754362800";
    private static final String BODY = "{\"type\":1}";

    private static DiscordProps 설정(
            boolean interactionEnabled,
            String publicKey
    ) {
        return new DiscordProps(false, interactionEnabled, publicKey, null, List.of(), List.of(), 10);
    }

    @Nested
    @DisplayName("요청 서명을 검증할 때")
    class IsValid {

        private final DiscordSignatureVerifier verifier = new DiscordSignatureVerifier(설정(true, DiscordTestKey.PUBLIC_KEY_HEX));

        @Test
        void 짝이_맞는_개인키로_서명한_요청은_통과한다() {
            // given
            String signature = DiscordTestKey.서명(TIMESTAMP, BODY);

            // when & then
            assertThat(verifier.isValid(signature, TIMESTAMP, BODY)).isTrue();
        }

        @Test
        void 본문이_바뀌면_실패한다() {
            // given
            String signature = DiscordTestKey.서명(TIMESTAMP, BODY);

            // when & then
            assertThat(verifier.isValid(signature, TIMESTAMP, "{\"type\":2}")).isFalse();
        }

        @Test
        void 타임스탬프가_바뀌면_실패한다() {
            // given
            String signature = DiscordTestKey.서명(TIMESTAMP, BODY);

            // when & then
            assertThat(verifier.isValid(signature, "1754362801", BODY)).isFalse();
        }

        @Test
        void 서명이_hex가_아니면_실패한다() {
            // when & then
            assertThat(verifier.isValid("not-hex-signature", TIMESTAMP, BODY)).isFalse();
        }

        @Test
        void 서명_길이가_맞지_않으면_실패한다() {
            // when & then
            assertThat(verifier.isValid("abcd", TIMESTAMP, BODY)).isFalse();
        }

        @Test
        void 서명이나_타임스탬프_헤더가_없으면_실패한다() {
            // given
            String signature = DiscordTestKey.서명(TIMESTAMP, BODY);

            // when & then
            assertThat(verifier.isValid(null, TIMESTAMP, BODY)).isFalse();
            assertThat(verifier.isValid(signature, null, BODY)).isFalse();
        }
    }

    @Nested
    @DisplayName("검증기를 만들 때")
    class Create {

        @Test
        void 조회_기능이_꺼져_있으면_공개키_없이_만들어지고_모든_요청을_거부한다() {
            // given
            DiscordSignatureVerifier verifier = new DiscordSignatureVerifier(설정(false, null));
            String signature = DiscordTestKey.서명(TIMESTAMP, BODY);

            // when & then
            assertThat(verifier.isValid(signature, TIMESTAMP, BODY)).isFalse();
        }

        @Test
        void 조회_기능이_켜져_있는데_공개키_형식이_틀리면_기동을_막는다() {
            // when & then
            assertThatThrownBy(() -> new DiscordSignatureVerifier(설정(true, "invalid-key")))
                    .isInstanceOf(IllegalStateException.class);
            assertThatThrownBy(() -> new DiscordSignatureVerifier(설정(true, "")))
                    .isInstanceOf(IllegalStateException.class);
            assertThatThrownBy(() -> new DiscordSignatureVerifier(설정(true, null)))
                    .isInstanceOf(IllegalStateException.class);
        }
    }
}
