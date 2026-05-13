package gravit.code.report.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.repository.ReportRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReportServiceUnitTest {

    @InjectMocks
    private ReportService reportService;

    @Mock
    private ReportRepository reportRepository;

    @Mock
    private ProblemRepository problemRepository;

    @Nested
    @DisplayName("문제를 신고할 때")
    class SubmitProblemReport {

        @Test
        void 문제가_존재하면_신고에_성공한다() {
            // given
            long userId = 1L;
            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest("CONTENT_ERROR", "문제 내용이 잘못되었습니다.", 1L);

            when(problemRepository.existsProblemById(1L)).thenReturn(true);
            when(reportRepository.save(any(Report.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            reportService.submitProblemReport(userId, request);

            // then
            verify(reportRepository).save(any(Report.class));
        }

        @Test
        void 문제가_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;
            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest("CONTENT_ERROR", "문제 내용이 잘못되었습니다.", 999L);

            when(problemRepository.existsProblemById(999L)).thenReturn(false);

            // when & then
            assertThatThrownBy(() -> reportService.submitProblemReport(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(PROBLEM_NOT_FOUND);

            verify(reportRepository, never()).save(any());
        }

        @Test
        void 신고_사유가_null이면_기본값으로_저장한다() {
            // given
            long userId = 1L;
            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest("TYPO_ERROR", null, 1L);

            when(problemRepository.existsProblemById(1L)).thenReturn(true);
            when(reportRepository.save(any(Report.class))).thenAnswer(inv -> inv.getArgument(0));

            // when
            reportService.submitProblemReport(userId, request);

            // then
            verify(reportRepository).save(any(Report.class));
        }
    }
}
