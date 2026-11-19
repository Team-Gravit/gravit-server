package gravit.code.report.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.dto.request.UserReportSubmitRequest;
import gravit.code.report.repository.ReportRepository;
import gravit.code.report.repository.UserReportRepository;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_DUPLICATED;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;
    private final UserReportRepository userReportRepository;
    private final ProblemRepository problemRepository;
    private final UserRepository userRepository;

    @Transactional
    public void submitProblemReport(
            long userId,
            ProblemReportSubmitRequest request
    ){
        if(!problemRepository.existsProblemById(request.problemId()))
            throw new RestApiException(PROBLEM_NOT_FOUND);

        reportRepository.save(Report.create(request, userId));
    }

    @Transactional
    public void submitUserReport(
            long reporterId,
            UserReportSubmitRequest request
    ) {
        User target = userRepository.findById(request.targetUserId())
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        UserReport userReport = UserReport.create(
                reporterId,
                target.getId(),
                UserReportType.from(request.reportType()),
                target.getNickname(),
                request.content()
        );

        if (userReportRepository.existsByReporterIdAndTargetUserIdAndIsResolvedFalse(reporterId, target.getId())) {
            throw new RestApiException(USER_REPORT_DUPLICATED);
        }

        try {
            userReportRepository.saveAndFlush(userReport);
        } catch (DataIntegrityViolationException e) {
            throw new RestApiException(USER_REPORT_DUPLICATED);
        }
    }
}
