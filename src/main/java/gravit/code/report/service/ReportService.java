package gravit.code.report.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.ProblemRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportRepository;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;
    private final ProblemRepository problemRepository;

    public Boolean saveReport(Long userId, ProblemReportSubmitRequest request){

        if(!problemRepository.existsProblemById(request.problemId()))
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        if(reportRepository.existsReportByProblemIdAndUserId(request.problemId(), userId))
            throw new RestApiException(CustomErrorCode.ALREADY_SUBMITTED_REPORT);

        reportRepository.save(Report.create(
                request.reportType(),
                request.content(),
                request.chapterId(),
                request.unitId(),
                request.lessonId(),
                request.problemId(),
                userId
        ));

        return true;
    }
}
