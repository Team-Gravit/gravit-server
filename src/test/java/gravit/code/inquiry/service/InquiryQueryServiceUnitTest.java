package gravit.code.inquiry.service;

import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.dto.response.InquiryDetailResponse;
import gravit.code.inquiry.dto.response.InquirySummaryResponse;
import gravit.code.inquiry.fixture.InquiryFixture;
import gravit.code.inquiry.repository.InquiryAnswerRepository;
import gravit.code.inquiry.repository.InquiryRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_FORBIDDEN;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PAGE_MUST_START_FROM_1;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class InquiryQueryServiceUnitTest {

    @InjectMocks
    private InquiryQueryService inquiryQueryService;

    @Mock
    private InquiryRepository inquiryRepository;

    @Mock
    private InquiryAnswerRepository inquiryAnswerRepository;

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long INQUIRY_ID = 10L;

    @Nested
    @DisplayName("본인 문의 목록을 조회할 때")
    class GetMyInquiries {

        @Test
        void 정상_조회되면_페이지_응답을_반환한다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, USER_ID);
            PageImpl<Inquiry> page = new PageImpl<>(List.of(inquiry), PageRequest.of(0, 10), 1);
            when(inquiryRepository.findAllByUserId(eq(USER_ID), any(Pageable.class))).thenReturn(page);

            // when
            PageResponse<InquirySummaryResponse> result = inquiryQueryService.getMyInquiries(USER_ID, 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.page()).isEqualTo(1);
                softly.assertThat(result.hasNext()).isFalse();
                softly.assertThat(result.contents()).hasSize(1);
                softly.assertThat(result.contents().get(0).id()).isEqualTo(INQUIRY_ID);
                softly.assertThat(result.contents().get(0).status()).isEqualTo("PENDING");
            });
        }

        @Test
        void 페이지가_1보다_작으면_예외를_던진다() {
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
        void 답변이_없으면_answer는_null이다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, USER_ID);
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));
            when(inquiryAnswerRepository.findByInquiryId(INQUIRY_ID)).thenReturn(Optional.empty());

            // when
            InquiryDetailResponse result = inquiryQueryService.getMyInquiryDetail(USER_ID, INQUIRY_ID);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.id()).isEqualTo(INQUIRY_ID);
                softly.assertThat(result.status()).isEqualTo("PENDING");
                softly.assertThat(result.answer()).isNull();
            });
        }

        @Test
        void 답변이_있으면_answer를_포함한다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, USER_ID);
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));
            when(inquiryAnswerRepository.findByInquiryId(INQUIRY_ID))
                    .thenReturn(Optional.of(InquiryFixture.답변(1L, INQUIRY_ID, 99L)));

            // when
            InquiryDetailResponse result = inquiryQueryService.getMyInquiryDetail(USER_ID, INQUIRY_ID);

            // then
            assertThat(result.answer()).isNotNull();
            assertThat(result.answer().content()).isEqualTo("확인 후 다음 배포에 반영했습니다.");
        }

        @Test
        void 존재하지_않는_문의면_예외를_던진다() {
            // given
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> inquiryQueryService.getMyInquiryDetail(USER_ID, INQUIRY_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }

        @Test
        void 본인의_문의가_아니면_예외를_던진다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, OTHER_USER_ID);
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when & then
            assertThatThrownBy(() -> inquiryQueryService.getMyInquiryDetail(USER_ID, INQUIRY_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_FORBIDDEN);
        }
    }
}
