package gravit.code.admin.service;

import gravit.code.admin.dto.response.UserReportListItemResponse;
import gravit.code.admin.repository.AdminUserReportRepository;
import gravit.code.admin.support.AdminPages;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_DUPLICATED;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminUserReportService {

    private final AdminUserReportRepository adminUserReportRepository;

    @Transactional(readOnly = true)
    public PageResponse<UserReportListItemResponse> getUserReports(
            int page,
            UserReportType reportType,
            Boolean isResolved
    ) {
        Pageable pageable = AdminPages.of(page);

        return PageResponse.from(
                adminUserReportRepository.search(reportType, isResolved, pageable)
                        .map(UserReportListItemResponse::from)
        );
    }

    @Transactional
    public void updateResolved(
            long reportId,
            boolean isResolved
    ) {
        UserReport userReport = adminUserReportRepository.findById(reportId)
                .orElseThrow(() -> new RestApiException(USER_REPORT_NOT_FOUND));

        userReport.changeResolved(isResolved);

        try {
            adminUserReportRepository.saveAndFlush(userReport);
        } catch (DataIntegrityViolationException e) {
            throw new RestApiException(USER_REPORT_DUPLICATED);
        }
    }
}
