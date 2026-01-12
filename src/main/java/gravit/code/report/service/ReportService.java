package gravit.code.report.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.repository.ReportRepository;
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

        reportRepository.save(Report.create(request, userId));
    }
}
