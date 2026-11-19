package gravit.code.user.policy;

import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.NICKNAME_BANNED_WORD;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class NicknameBannedWordPolicyTest {

    private static final List<String> BANNED_WORDS = List.of("금지", "badword", "운영자");
    private static final List<String> ALLOWED_WORDS = List.of("금지옥엽");

    private final NicknameBannedWordPolicy policy = new NicknameBannedWordPolicy(BANNED_WORDS, ALLOWED_WORDS);

    private void 금지어로_거절된다(String nickname) {
        assertThatThrownBy(() -> policy.validate(nickname))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(NICKNAME_BANNED_WORD);
    }

    private void 통과한다(String nickname) {
        assertThatCode(() -> policy.validate(nickname)).doesNotThrowAnyException();
    }

    @Nested
    @DisplayName("금지어가 들어 있으면")
    class ContainsBannedWord {

        @Test
        void 금지어_그대로면_예외를_던진다() {
            금지어로_거절된다("금지");
        }

        @Test
        void 금지어가_중간에_들어_있어도_예외를_던진다() {
            금지어로_거절된다("나는금지야");
        }

        @Test
        void 대문자로_써도_예외를_던진다() {
            금지어로_거절된다("BADWORD");
        }

        @Test
        void 전각_문자로_써도_예외를_던진다() {
            금지어로_거절된다("ＢＡＤＷＯＲＤ");
        }

        @Test
        void 사이에_숫자를_끼워도_예외를_던진다() {
            금지어로_거절된다("금1지");
        }

        @Test
        void 사칭_예약어가_들어_있으면_예외를_던진다() {
            금지어로_거절된다("운영자1");
        }

        @Test
        void 허용_단어를_가린_뒤에도_금지어가_남으면_예외를_던진다() {
            금지어로_거절된다("금지옥엽금지");
        }
    }

    @Nested
    @DisplayName("금지어가 없거나 허용 단어이면")
    class NoBannedWord {

        @Test
        void 금지어가_없으면_통과한다() {
            통과한다("코딩왕");
        }

        @Test
        void 금지어를_품은_허용_단어는_통과한다() {
            통과한다("금지옥엽");
        }

        @Test
        void 허용_단어_사이에_숫자를_끼워도_통과한다() {
            통과한다("금1지옥엽");
        }

        @Test
        void null이면_검사하지_않고_통과한다() {
            통과한다(null);
        }

        @Test
        void 빈_문자열이면_검사하지_않고_통과한다() {
            통과한다(" ");
        }
    }

    @Nested
    @DisplayName("금지어 목록을 만들 때")
    class Create {

        @Test
        void 금지어_목록이_비어_있으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> new NicknameBannedWordPolicy(List.of(), ALLOWED_WORDS))
                    .isInstanceOf(IllegalStateException.class);
        }
    }
}
