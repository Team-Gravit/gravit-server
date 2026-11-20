package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminUserReportControllerDocs;
import gravit.code.admin.dto.request.ReportStatusUpdateRequest;
import gravit.code.admin.dto.response.UserReportListItemResponse;
import gravit.code.admin.service.AdminUserReportService;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.report.domain.UserReportType;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/user-reports")
public class AdminUserReportController implements AdminUserReportControllerDocs {

    private final AdminUserReportService adminUserReportService;

    @GetMapping
    public ResponseEntity<PageResponse<UserReportListItemResponse>> getUserReports(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "reportType", required = false) UserReportType reportType,
            @RequestParam(value = "isResolved", required = false) Boolean isResolved
    ) {
        return ResponseEntity.status(OK).body(adminUserReportService.getUserReports(page, reportType, isResolved));
    }

    @PatchMapping("/{reportId}/status")
    public ResponseEntity<Void> updateStatus(
            @PathVariable("reportId") Long reportId,
            @Valid @RequestBody ReportStatusUpdateRequest request
    ) {
        adminUserReportService.updateResolved(reportId, request.isResolved());
        return ResponseEntity.status(OK).build();
    }
}
