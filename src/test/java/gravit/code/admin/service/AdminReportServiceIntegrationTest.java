package gravit.code.admin.service;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import gravit.code.report.repository.ReportRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class AdminReportServiceIntegrationTest {

    @Autowired
    private AdminReportService adminReportService;

    @Autowired
    private ReportRepository reportRepository;

    private Report saveReport(
            ReportType type,
            long problemId,
            boolean resolved
    ) {
        Report report = Report.of(type, "신고 내용", problemId, 100L);
        if (resolved) {
            report.changeResolved(true);
        }
        return reportRepository.save(report);
    }

    @Test
    @DisplayName("신고 목록: reportType 필터 + 최신순(id DESC)")
    void getReports_filterByType() {
        saveReport(ReportType.TYPO_ERROR, 10L, false);
        saveReport(ReportType.CONTENT_ERROR, 11L, false);
        saveReport(ReportType.TYPO_ERROR, 12L, false);

        PageResponse<ReportListItemResponse> result = adminReportService.getReports(1, ReportType.TYPO_ERROR, null);

        assertThat(result.contents()).hasSize(2);
        assertThat(result.contents()).allMatch(r -> r.reportType() == ReportType.TYPO_ERROR);
        assertThat(result.contents().get(0).reportId()).isGreaterThan(result.contents().get(1).reportId());
    }

    @Test
    @DisplayName("신고 목록: isResolved 필터")
    void getReports_filterByResolved() {
        saveReport(ReportType.TYPO_ERROR, 10L, false);
        saveReport(ReportType.CONTENT_ERROR, 11L, true);

        PageResponse<ReportListItemResponse> unresolved = adminReportService.getReports(1, null, false);
        PageResponse<ReportListItemResponse> resolvedList = adminReportService.getReports(1, null, true);

        assertThat(unresolved.contents()).hasSize(1);
        assertThat(unresolved.contents().get(0).isResolved()).isFalse();
        assertThat(resolvedList.contents()).hasSize(1);
        assertThat(resolvedList.contents().get(0).isResolved()).isTrue();
    }

    @Test
    @DisplayName("신고 상세 조회 (신고자 미노출)")
    void getReport_detail() {
        Report report = saveReport(ReportType.ANSWER_ERROR, 33L, false);

        ReportDetailResponse detail = adminReportService.getReport(report.getId());

        assertThat(detail.reportId()).isEqualTo(report.getId());
        assertThat(detail.problemId()).isEqualTo(33L);
        assertThat(detail.reportType()).isEqualTo(ReportType.ANSWER_ERROR);
    }

    @Test
    @DisplayName("신고 상세 조회 실패 시 REPORT_NOT_FOUND")
    void getReport_notFound() {
        assertThatThrownBy(() -> adminReportService.getReport(99999L))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.REPORT_NOT_FOUND);
    }

    @Test
    @DisplayName("신고 처리 상태 명시적 set (toggle 아님)")
    void updateResolved_explicitSet() {
        Report report = saveReport(ReportType.OTHER_ERROR, 10L, false);

        adminReportService.updateResolved(report.getId(), true);
        assertThat(adminReportService.getReport(report.getId()).isResolved()).isTrue();

        adminReportService.updateResolved(report.getId(), true);
        assertThat(adminReportService.getReport(report.getId()).isResolved()).isTrue();

        adminReportService.updateResolved(report.getId(), false);
        assertThat(adminReportService.getReport(report.getId()).isResolved()).isFalse();
    }
}
