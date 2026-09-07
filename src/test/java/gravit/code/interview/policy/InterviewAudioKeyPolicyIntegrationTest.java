package gravit.code.interview.policy;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAudioFormat;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.EnumSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_KEY_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class InterviewAudioKeyPolicyIntegrationTest {

    private static final long SESSION_ID = 12L;
    private static final long OTHER_SESSION_ID = 13L;
    private static final int DISPLAY_ORDER = 3;
    private static final int OTHER_DISPLAY_ORDER = 4;

    @Autowired
    private InterviewAudioKeyPolicy interviewAudioKeyPolicy;

    @Nested
    @DisplayName("음성 키를 발급할 때")
    class Issue {

        @ParameterizedTest
        @CsvSource({
                "M4A, m4a",
                "MP4, m4a",
                "WEBM, webm",
                "MPEG, mp3"
        })
        void 세션과_문항과_확장자로_키를_만든다(
                InterviewAudioFormat format,
                String extension
        ) {
            // when
            String audioKey = interviewAudioKeyPolicy.issue(SESSION_ID, DISPLAY_ORDER, format);

            // then
            assertThat(audioKey).isEqualTo("interview/12/3." + extension);
        }

        @Test
        void 같은_세션과_문항이면_항상_같은_키가_나온다() {
            // when
            String first = interviewAudioKeyPolicy.issue(SESSION_ID, DISPLAY_ORDER, InterviewAudioFormat.M4A);
            String second = interviewAudioKeyPolicy.issue(SESSION_ID, DISPLAY_ORDER, InterviewAudioFormat.M4A);

            // then
            assertThat(first).isEqualTo(second);
        }

        @Test
        void 문항이_다르면_키가_다르다() {
            // when
            String first = interviewAudioKeyPolicy.issue(SESSION_ID, DISPLAY_ORDER, InterviewAudioFormat.M4A);
            String second = interviewAudioKeyPolicy.issue(SESSION_ID, OTHER_DISPLAY_ORDER, InterviewAudioFormat.M4A);

            // then
            assertThat(first).isNotEqualTo(second);
        }
    }

    @Nested
    @DisplayName("음성 키를 검증할 때")
    class Validate {

        @ParameterizedTest
        @EnumSource(InterviewAudioFormat.class)
        void 발급한_키는_같은_세션과_문항으로_검증을_통과한다(InterviewAudioFormat format) {
            // given
            String audioKey = interviewAudioKeyPolicy.issue(SESSION_ID, DISPLAY_ORDER, format);

            // when & then
            assertThatCode(() -> interviewAudioKeyPolicy.validate(SESSION_ID, DISPLAY_ORDER, audioKey))
                    .doesNotThrowAnyException();
        }

        @Test
        void 다른_세션의_키면_예외를_던진다() {
            // given
            String audioKey = interviewAudioKeyPolicy.issue(OTHER_SESSION_ID, DISPLAY_ORDER, InterviewAudioFormat.M4A);

            // when & then
            assertThatThrownBy(() -> interviewAudioKeyPolicy.validate(SESSION_ID, DISPLAY_ORDER, audioKey))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_KEY_INVALID);
        }

        @Test
        void 다른_문항의_키면_예외를_던진다() {
            // given
            String audioKey = interviewAudioKeyPolicy.issue(SESSION_ID, OTHER_DISPLAY_ORDER, InterviewAudioFormat.M4A);

            // when & then
            assertThatThrownBy(() -> interviewAudioKeyPolicy.validate(SESSION_ID, DISPLAY_ORDER, audioKey))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_KEY_INVALID);
        }

        @ParameterizedTest
        @ValueSource(strings = {
                "interview/12/3.sh",
                "interview/12/3.",
                "interview/12/3",
                "interview/12/3.m4a/../../13/1.m4a",
                "hacked",
                "https://evil.example.com/interview/12/3.m4a",
                "/interview/12/3.m4a"
        })
        void 서버가_발급한_형식이_아니면_예외를_던진다(String audioKey) {
            // when & then
            assertThatThrownBy(() -> interviewAudioKeyPolicy.validate(SESSION_ID, DISPLAY_ORDER, audioKey))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_KEY_INVALID);
        }
    }
}
