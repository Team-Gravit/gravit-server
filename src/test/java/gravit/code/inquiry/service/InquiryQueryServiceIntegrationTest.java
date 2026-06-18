package gravit.code.inquiry.service;

import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import gravit.code.inquiry.domain.InquiryType;
import gravit.code.inquiry.dto.response.InquiryDetailResponse;
import gravit.code.inquiry.dto.response.InquirySummaryResponse;
import gravit.code.inquiry.repository.InquiryAnswerRepository;
import gravit.code.inquiry.repository.InquiryRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_FORBIDDEN;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PAGE_MUST_START_FROM_1;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InquiryQueryServiceIntegrationTest {

    @Autowired
    private InquiryQueryService inquiryQueryService;

    @Autowired
    private InquiryRepository inquiryRepository;

    @Autowired
    private InquiryAnswerRepository inquiryAnswerRepository;

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long ADMIN_ID = 99L;

    @Nested
    @DisplayName("본인 문의 목록을 조회할 때")
    class GetMyInquiries {

        @Test
        void 본인_문의만_id_내림차순으로_페이징되어_조회된다() {
            // given
            Inquiry first = saveInquiry(USER_ID, "첫 번째");
            Inquiry second = saveInquiry(USER_ID, "두 번째");
            saveInquiry(OTHER_USER_ID, "남의 문의");

            // when
            PageResponse<InquirySummaryResponse> result = inquiryQueryService.getMyInquiries(USER_ID, 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.page()).isEqualTo(1);
                softly.assertThat(result.hasNext()).isFalse();
                softly.assertThat(result.contents()).hasSize(2);
                // id 내림차순 → 나중에 저장된 second 가 먼저
                softly.assertThat(result.contents().get(0).id()).isEqualTo(second.getId());
                softly.assertThat(result.contents().get(1).id()).isEqualTo(first.getId());
            });
        }

        @Test
        void soft_delete된_문의는_목록에서_제외된다() {
            // given
            Inquiry kept = saveInquiry(USER_ID, "유지");
            Inquiry deleted = saveInquiry(USER_ID, "삭제");
            inquiryRepository.delete(deleted);

            // when
            PageResponse<InquirySummaryResponse> result = inquiryQueryService.getMyInquiries(USER_ID, 1);

            // then
            assertThat(result.contents()).hasSize(1);
            assertThat(result.contents().get(0).id()).isEqualTo(kept.getId());
        }

        @Test
        void 작성한_문의가_없으면_빈_목록을_반환한다() {
            // when
            PageResponse<InquirySummaryResponse> result = inquiryQueryService.getMyInquiries(USER_ID, 1);

            // then
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 페이지가_1보다_작으면_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> inquiryQueryService.getMyInquiries(USER_ID, 0))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PAGE_MUST_START_FROM_1);
        }
    }

    @Nested
    @DisplayName("본인 문의 상세를 조회할 때")
    class GetMyInquiryDetail {

        @Test
        void 답변이_없으면_answer가_null이다() {
            // given
            Inquiry inquiry = saveInquiry(USER_ID, "문의");

            // when
            InquiryDetailResponse result = inquiryQueryService.getMyInquiryDetail(USER_ID, inquiry.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.id()).isEqualTo(inquiry.getId());
                softly.assertThat(result.status()).isEqualTo("PENDING");
                softly.assertThat(result.answer()).isNull();
            });
        }

        @Test
        void 답변이_있으면_answer를_포함한다() {
            // given
            Inquiry inquiry = saveInquiry(USER_ID, "문의");
            inquiryAnswerRepository.save(InquiryAnswer.create(inquiry.getId(), "처리 완료했습니다.", ADMIN_ID));

            // when
            InquiryDetailResponse result = inquiryQueryService.getMyInquiryDetail(USER_ID, inquiry.getId());

            // then
            assertThat(result.answer()).isNotNull();
            assertThat(result.answer().content()).isEqualTo("처리 완료했습니다.");
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> inquiryQueryService.getMyInquiryDetail(USER_ID, 999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }

        @Test
        void soft_delete된_문의면_예외가_발생한다() {
            // given
            Inquiry inquiry = saveInquiry(USER_ID, "문의");
            inquiryRepository.delete(inquiry);

            // when & then
            assertThatThrownBy(() -> inquiryQueryService.getMyInquiryDetail(USER_ID, inquiry.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }

        @Test
        void 본인의_문의가_아니면_예외가_발생한다() {
            // given
            Inquiry inquiry = saveInquiry(OTHER_USER_ID, "남의 문의");

            // when & then
            assertThatThrownBy(() -> inquiryQueryService.getMyInquiryDetail(USER_ID, inquiry.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_FORBIDDEN);
        }
    }

    private Inquiry saveInquiry(
            long userId,
            String title
    ) {
        return inquiryRepository.save(
                Inquiry.create(title, InquiryType.BUG_REPORT, "내용", userId)
        );
    }
}
