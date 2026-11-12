package gravit.code.inquiry.service;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryStatus;
import gravit.code.inquiry.domain.InquiryType;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.repository.InquiryRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InquiryCommandServiceIntegrationTest {

    @Autowired
    private InquiryCommandService inquiryCommandService;

    @Autowired
    private InquiryRepository inquiryRepository;

    private static final long USER_ID = 1L;

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
}
