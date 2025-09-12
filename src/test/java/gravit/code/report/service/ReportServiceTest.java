package gravit.code.report.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.ProblemRepository;
import gravit.code.report.domain.ReportRepository;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;


@ExtendWith(MockitoExtension.class)
class ReportServiceTest {

    @Mock
    private ReportRepository reportRepository;

    @Mock
    private ProblemRepository problemRepository;

    @InjectMocks
    private ReportService reportService;

    @Nested
    @DisplayName("문제 신고를 제출하려고 할 때,")
    class SubmitProblemReport{

        @Test
        @DisplayName("문제가 존재하지 않으면 예외를 반환한다.")
        void withInvalidProblemId(){
            //given
            Long userId = 1L;
            Long problemId = 1L;

            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest(
                    "TYPO_ERROR",
                    "문제에 오탈자가 있습니다.",
                    problemId
            );

            when(problemRepository.existsProblemById(request.problemId())).thenReturn(false);

            //when & then
            assertThatThrownBy(() -> reportService.saveReport(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.PROBLEM_NOT_FOUND);
        }

        @Test
        @DisplayName("이미 제출된 신고라면 예외를 반환한다.")
        void withAlreadySubmittedData(){
            //given
            Long userId = 1L;
            Long problemId = 1L;

            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest(
                    "TYPO_ERROR",
                    "문제에 오탈자가 있습니다.",
                    problemId
            );

            when(problemRepository.existsProblemById(request.problemId())).thenReturn(true);
            when(reportRepository.existsReportByProblemIdAndUserId(request.problemId(), userId)).thenReturn(true);

            //when & then
            assertThatThrownBy(() -> reportService.saveReport(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode" ,CustomErrorCode.ALREADY_SUBMITTED_REPORT);
        }


        @Test
        @DisplayName("데이터가 유효하면 문제 신고에 성공한다.")
        void withValidRequestData(){
            //given
            Long userId = 1L;
            Long problemId = 1L;

            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest(
                    "TYPO_ERROR",
                    "문제에 오탈자가 있습니다.",
                    problemId
            );

            when(problemRepository.existsProblemById(request.problemId())).thenReturn(true);
            when(reportRepository.existsReportByProblemIdAndUserId(request.problemId(), userId)).thenReturn(false);

            //when
            boolean result = reportService.saveReport(userId, request);

            //then
            assertThat(result).isTrue();
        }
    }
}