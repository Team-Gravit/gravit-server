package gravit.code.inquiry.service;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.fixture.InquiryFixture;
import gravit.code.inquiry.repository.InquiryRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class InquiryCommandServiceUnitTest {

    @InjectMocks
    private InquiryCommandService inquiryCommandService;

    @Mock
    private InquiryRepository inquiryRepository;

    private static final long USER_ID = 1L;
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
}
