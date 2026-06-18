package gravit.code.inquiry.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.dto.request.InquiryUpdateRequest;
import gravit.code.inquiry.fixture.InquiryFixture;
import gravit.code.inquiry.repository.InquiryRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_ALREADY_RESOLVED;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_FORBIDDEN;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class InquiryCommandServiceUnitTest {

    @InjectMocks
    private InquiryCommandService inquiryCommandService;

    @Mock
    private InquiryRepository inquiryRepository;

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long INQUIRY_ID = 10L;

    @Nested
    @DisplayName("문의를 제출할 때")
    class Submit {

        @Test
        void 정상_제출되면_생성된_문의_ID를_반환한다() {
            // given
            InquirySubmitRequest request = new InquirySubmitRequest("제목", "BUG_REPORT", "내용");
            when(inquiryRepository.save(any(Inquiry.class)))
                    .thenReturn(InquiryFixture.기본_문의(INQUIRY_ID, USER_ID));

            // when
            long savedId = inquiryCommandService.submit(USER_ID, request);

            // then
            assertThat(savedId).isEqualTo(INQUIRY_ID);
            verify(inquiryRepository).save(any(Inquiry.class));
        }
    }

    @Nested
    @DisplayName("문의를 수정할 때")
    class Update {

        @Test
        void 본인의_미해결_문의면_수정에_성공한다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, USER_ID);
            InquiryUpdateRequest request = new InquiryUpdateRequest("새 제목", "FEATURE_SUGGESTION", "새 내용");
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when
            inquiryCommandService.update(USER_ID, INQUIRY_ID, request);

            // then
            assertThat(inquiry.getTitle()).isEqualTo("새 제목");
            assertThat(inquiry.getContent()).isEqualTo("새 내용");
        }

        @Test
        void 존재하지_않는_문의면_예외를_던진다() {
            // given
            InquiryUpdateRequest request = new InquiryUpdateRequest("새 제목", "OTHER", "새 내용");
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.update(USER_ID, INQUIRY_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }

        @Test
        void 본인의_문의가_아니면_예외를_던진다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, OTHER_USER_ID);
            InquiryUpdateRequest request = new InquiryUpdateRequest("새 제목", "OTHER", "새 내용");
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.update(USER_ID, INQUIRY_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_FORBIDDEN);
        }

        @Test
        void 이미_해결된_문의면_예외를_던진다() {
            // given
            Inquiry inquiry = InquiryFixture.해결된_문의(INQUIRY_ID, USER_ID);
            InquiryUpdateRequest request = new InquiryUpdateRequest("새 제목", "OTHER", "새 내용");
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.update(USER_ID, INQUIRY_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_RESOLVED);
        }
    }

    @Nested
    @DisplayName("문의를 삭제할 때")
    class Delete {

        @Test
        void 본인의_미해결_문의면_삭제에_성공한다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, USER_ID);
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when
            inquiryCommandService.delete(USER_ID, INQUIRY_ID);

            // then
            verify(inquiryRepository).delete(inquiry);
        }

        @Test
        void 존재하지_않는_문의면_예외를_던진다() {
            // given
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.delete(USER_ID, INQUIRY_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
            verify(inquiryRepository, never()).delete(any());
        }

        @Test
        void 본인의_문의가_아니면_예외를_던진다() {
            // given
            Inquiry inquiry = InquiryFixture.기본_문의(INQUIRY_ID, OTHER_USER_ID);
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.delete(USER_ID, INQUIRY_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_FORBIDDEN);
            verify(inquiryRepository, never()).delete(any());
        }

        @Test
        void 이미_해결된_문의면_예외를_던지고_삭제하지_않는다() {
            // given
            Inquiry inquiry = InquiryFixture.해결된_문의(INQUIRY_ID, USER_ID);
            when(inquiryRepository.findById(INQUIRY_ID)).thenReturn(Optional.of(inquiry));

            // when & then
            assertThatThrownBy(() -> inquiryCommandService.delete(USER_ID, INQUIRY_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_RESOLVED);
            verify(inquiryRepository, never()).delete(any());
        }
    }
}
