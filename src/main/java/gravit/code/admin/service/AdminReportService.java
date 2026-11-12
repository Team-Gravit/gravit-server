package gravit.code.admin.service;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportListItemResponse;
import gravit.code.admin.repository.AdminReportRepository;
import gravit.code.admin.support.AdminPages;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.REPORT_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminReportService {

    private final AdminReportRepository adminReportRepository;

    @Transactional(readOnly = true)
    public PageResponse<ReportListItemResponse> getReports(
            int page,
            ReportType reportType,
            Boolean isResolved
    ) {
        Pageable pageable = AdminPages.of(page);

        return PageResponse.from(
                adminReportRepository.search(reportType, isResolved, pageable)
                        .map(ReportListItemResponse::from)
        );
    }

    @Transactional(readOnly = true)
    public ReportDetailResponse getReport(long reportId) {
        Report report = adminReportRepository.findById(reportId)
                .orElseThrow(() -> new RestApiException(REPORT_NOT_FOUND));

        return ReportDetailResponse.from(report);
    }

    @Transactional
    public void updateResolved(
            long reportId,
            boolean isResolved
    ) {
        Report report = adminReportRepository.findById(reportId)
                .orElseThrow(() -> new RestApiException(REPORT_NOT_FOUND));

        report.changeResolved(isResolved);
    }
}
