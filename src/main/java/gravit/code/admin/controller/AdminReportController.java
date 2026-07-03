package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminReportControllerDocs;
import gravit.code.admin.dto.request.ReportStatusUpdateRequest;
import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportListItemResponse;
import gravit.code.admin.service.AdminReportService;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.report.domain.ReportType;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/reports")
public class AdminReportController implements AdminReportControllerDocs {

    private final AdminReportService adminReportService;

    @GetMapping
    public ResponseEntity<PageResponse<ReportListItemResponse>> getReports(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "reportType", required = false) ReportType reportType,
            @RequestParam(value = "isResolved", required = false) Boolean isResolved
    ) {
        return ResponseEntity.status(HttpStatus.OK).body(adminReportService.getReports(page, reportType, isResolved));
    }

    @GetMapping("/{reportId}")
    public ResponseEntity<ReportDetailResponse> getReport(@PathVariable("reportId") Long reportId) {
        return ResponseEntity.status(HttpStatus.OK).body(adminReportService.getReport(reportId));
    }

    @PatchMapping("/{reportId}/status")
    public ResponseEntity<Void> updateStatus(
            @PathVariable("reportId") Long reportId,
            @Valid @RequestBody ReportStatusUpdateRequest request
    ) {
        adminReportService.updateResolved(reportId, request.isResolved());
        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
