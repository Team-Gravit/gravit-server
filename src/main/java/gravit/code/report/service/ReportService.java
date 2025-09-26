package gravit.code.report.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.ProblemRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportRepository;
import gravit.code.report.domain.ReportType;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;
    private final ProblemRepository problemRepository;

    @Transactional
    public void submitProblemReport(
            long userId,
            ProblemReportSubmitRequest request
    ){

        if(!problemRepository.existsProblemById(request.problemId()))
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        if(reportRepository.existsReportByProblemIdAndUserId(request.problemId(), userId))
            throw new RestApiException(CustomErrorCode.ALREADY_SUBMITTED_REPORT);

        reportRepository.save(Report.create(
                ReportType.from(request.reportType()),
                request.content(),
                request.problemId(),
                userId
        ));
    }
}
