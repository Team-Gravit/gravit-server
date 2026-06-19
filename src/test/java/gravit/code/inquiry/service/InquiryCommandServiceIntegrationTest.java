package gravit.code.inquiry.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryStatus;
import gravit.code.inquiry.domain.InquiryType;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.dto.request.InquiryUpdateRequest;
import gravit.code.inquiry.repository.InquiryRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.util.ReflectionTestUtils;

import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_ALREADY_RESOLVED;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_FORBIDDEN;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InquiryCommandServiceIntegrationTest {

    @Autowired
    private InquiryCommandService inquiryCommandService;

    @Autowired
    private InquiryRepository inquiryRepository;

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;

    @Nested
    @DisplayName("문의를 제출할 때")
    class Submit {

        @Test
        void 정상_제출되면_PENDING_상태로_저장된다() {
            // given
            InquirySubmitRequest request = new InquirySubmitRequest("앱 종료 문의", "BUG_REPORT", "앱이 종료됩니다.");

            // when
            long savedId = inquiryCommandService.submit(USER_ID, request);

            // then
            Inquiry saved = inquiryRepository.findById(savedId).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(saved.getTitle()).isEqualTo("앱 종료 문의");
                softly.assertThat(saved.getType()).isEqualTo(InquiryType.BUG_REPORT);
                softly.assertThat(saved.getContent()).isEqualTo("앱이 종료됩니다.");
                softly.assertThat(saved.getStatus()).isEqualTo(InquiryStatus.PENDING);
                softly.assertThat(saved.getUserId()).isEqualTo(USER_ID);
                softly.assertThat(saved.getCreatedAt()).isNotNull();
            });
        }
    }

    @Nested
    @DisplayName("문의를 수정할 때")
    class Update {

        @Test
        void 본인의_미해결_문의면_수정된다() {
            // given
            Inquiry inquiry = savePendingInquiry(USER_ID);
            InquiryUpdateRequest request = new InquiryUpdateRequest("수정된 제목", "FEATURE_SUGGESTION", "수정된 내용");

            // when
            inquiryCommandService.update(USER_ID, inquiry.getId(), request);

            // then
            Inquiry updated = inquiryRepository.findById(inquiry.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(updated.getTitle()).isEqualTo("수정된 제목");
                softly.assertThat(updated.getType()).isEqualTo(InquiryType.FEATURE_SUGGESTION);
                softly.assertThat(updated.getContent()).isEqualTo("수정된 내용");
            });
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // given
            InquiryUpdateRequest request = new InquiryUpdateRequest("수정", "OTHER", "내용");

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.update(USER_ID, 999L, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }

        @Test
        void 본인의_문의가_아니면_예외가_발생한다() {
            // given
            Inquiry inquiry = savePendingInquiry(OTHER_USER_ID);
            InquiryUpdateRequest request = new InquiryUpdateRequest("수정", "OTHER", "내용");

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.update(USER_ID, inquiry.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_FORBIDDEN);
        }

        @Test
        void 이미_해결된_문의면_예외가_발생한다() {
            // given
            Inquiry inquiry = saveResolvedInquiry(USER_ID);
            InquiryUpdateRequest request = new InquiryUpdateRequest("수정", "OTHER", "내용");

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.update(USER_ID, inquiry.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_RESOLVED);
        }
    }

    @Nested
    @DisplayName("문의를 삭제할 때")
    class Delete {

        @Test
        void 본인의_미해결_문의면_soft_delete되어_조회되지_않는다() {
            // given
            Inquiry inquiry = savePendingInquiry(USER_ID);

            // when
            inquiryCommandService.delete(USER_ID, inquiry.getId());

            // then
            assertThat(inquiryRepository.findById(inquiry.getId())).isEmpty();
            assertThat(inquiryRepository.count()).isZero();
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> inquiryCommandService.delete(USER_ID, 999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }

        @Test
        void 본인의_문의가_아니면_예외가_발생한다() {
            // given
            Inquiry inquiry = savePendingInquiry(OTHER_USER_ID);

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.delete(USER_ID, inquiry.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_FORBIDDEN);
            assertThat(inquiryRepository.findById(inquiry.getId())).isPresent();
        }

        @Test
        void 이미_해결된_문의면_예외가_발생하고_삭제되지_않는다() {
            // given
            Inquiry inquiry = saveResolvedInquiry(USER_ID);

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.delete(USER_ID, inquiry.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_RESOLVED);
            assertThat(inquiryRepository.findById(inquiry.getId())).isPresent();
        }
    }

    private Inquiry savePendingInquiry(long userId) {
        return inquiryRepository.save(
                Inquiry.create("기본 제목", InquiryType.BUG_REPORT, "기본 내용", userId)
        );
    }

    private Inquiry saveResolvedInquiry(long userId) {
        Inquiry inquiry = Inquiry.create("해결된 문의", InquiryType.BUG_REPORT, "내용", userId);
        ReflectionTestUtils.setField(inquiry, "status", InquiryStatus.RESOLVED);
        return inquiryRepository.save(inquiry);
    }
}
