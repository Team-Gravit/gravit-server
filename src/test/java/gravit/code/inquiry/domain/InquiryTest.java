package gravit.code.inquiry.domain;

import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_ALREADY_RESOLVED;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_CONTENT_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_TITLE_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@DisplayName("Inquiry 엔티티")
class InquiryTest {

    private static final long USER_ID = 1L;

    @Nested
    @DisplayName("문의를 생성할 때")
    class Create {

        @Test
        void 정상_생성되면_상태는_PENDING이고_제목은_trim된다() {
            // given & when
            Inquiry inquiry = Inquiry.create("  앱 종료 문의  ", InquiryType.BUG_REPORT, "내용입니다.", USER_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(inquiry.getStatus()).isEqualTo(InquiryStatus.PENDING);
                softly.assertThat(inquiry.getTitle()).isEqualTo("앱 종료 문의");
                softly.assertThat(inquiry.getType()).isEqualTo(InquiryType.BUG_REPORT);
                softly.assertThat(inquiry.getContent()).isEqualTo("내용입니다.");
                softly.assertThat(inquiry.getUserId()).isEqualTo(USER_ID);
            });
        }

        @Test
        void 제목이_공백이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> Inquiry.create("   ", InquiryType.OTHER, "내용", USER_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_TITLE_INVALID);
        }

        @Test
        void 제목이_50자를_초과하면_예외를_던진다() {
            // given
            String tooLong = "가".repeat(51);

            // when & then
            assertThatThrownBy(() -> Inquiry.create(tooLong, InquiryType.OTHER, "내용", USER_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_TITLE_INVALID);
        }

        @Test
        void 내용이_공백이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> Inquiry.create("제목", InquiryType.OTHER, "   ", USER_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_CONTENT_INVALID);
        }
    }

    @Nested
    @DisplayName("문의를 수정할 때")
    class Update {

        @Test
        void 미해결_상태면_수정에_성공한다() {
            // given
            Inquiry inquiry = Inquiry.create("이전 제목", InquiryType.BUG_REPORT, "이전 내용", USER_ID);

            // when
            inquiry.update("새 제목", InquiryType.FEATURE_SUGGESTION, "새 내용");

            // then
            assertSoftly(softly -> {
                softly.assertThat(inquiry.getTitle()).isEqualTo("새 제목");
                softly.assertThat(inquiry.getType()).isEqualTo(InquiryType.FEATURE_SUGGESTION);
                softly.assertThat(inquiry.getContent()).isEqualTo("새 내용");
            });
        }

        @Test
        void 이미_해결된_문의면_예외를_던진다() {
            // given
            Inquiry inquiry = Inquiry.create("제목", InquiryType.BUG_REPORT, "내용", USER_ID);
            ReflectionTestUtils.setField(inquiry, "status", InquiryStatus.RESOLVED);

            // when & then
            assertThatThrownBy(() -> inquiry.update("새 제목", InquiryType.OTHER, "새 내용"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_RESOLVED);
        }

        @Test
        void 수정_제목이_공백이면_예외를_던진다() {
            // given
            Inquiry inquiry = Inquiry.create("제목", InquiryType.BUG_REPORT, "내용", USER_ID);

            // when & then
            assertThatThrownBy(() -> inquiry.update("  ", InquiryType.OTHER, "새 내용"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_TITLE_INVALID);
        }
    }

    @Nested
    @DisplayName("수정 가능 여부를 검증할 때")
    class EnsureModifiable {

        @Test
        void 미해결이면_예외없이_통과한다() {
            // given
            Inquiry inquiry = Inquiry.create("제목", InquiryType.BUG_REPORT, "내용", USER_ID);

            // when & then
            assertThatCode(inquiry::ensureModifiable).doesNotThrowAnyException();
        }

        @Test
        void 해결됐으면_예외를_던진다() {
            // given
            Inquiry inquiry = Inquiry.create("제목", InquiryType.BUG_REPORT, "내용", USER_ID);
            ReflectionTestUtils.setField(inquiry, "status", InquiryStatus.RESOLVED);

            // when & then
            assertThatThrownBy(inquiry::ensureModifiable)
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_RESOLVED);
        }
    }

    @Nested
    @DisplayName("소유자를 검증할 때")
    class IsOwnedBy {

        @Test
        void 동일한_유저면_true를_반환한다() {
            // given
            Inquiry inquiry = Inquiry.create("제목", InquiryType.BUG_REPORT, "내용", USER_ID);

            // when & then
            assertThat(inquiry.isOwnedBy(USER_ID)).isTrue();
        }

        @Test
        void 다른_유저면_false를_반환한다() {
            // given
            Inquiry inquiry = Inquiry.create("제목", InquiryType.BUG_REPORT, "내용", USER_ID);

            // when & then
            assertThat(inquiry.isOwnedBy(999L)).isFalse();
        }
    }
}
