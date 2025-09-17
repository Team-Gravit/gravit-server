package gravit.code.admin.controller;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportSummaryResponse;
import gravit.code.admin.service.AdminReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/reports")
public class AdminReportController {

    private final AdminReportService adminReportService;

    @GetMapping
    public ResponseEntity<List<ReportSummaryResponse>> getAllReportSummary(@RequestParam(value = "page", defaultValue = "0") int page){
        return ResponseEntity.status(HttpStatus.OK).body(adminReportService.getAllReportSummary(page));
    }

    @GetMapping("/{reportId}")
    public ResponseEntity<ReportDetailResponse> getReportDetail(@PathVariable("reportId") Long reportId){
        return ResponseEntity.status(HttpStatus.OK).body(adminReportService.getReportDetail(reportId));
    }

    @PatchMapping("/{reportId}/status")
    public ResponseEntity<Boolean> updateResolvedStatus(@PathVariable("reportId") Long reportId){
        return ResponseEntity.status(HttpStatus.OK).body(adminReportService.updateResolvedStatus(reportId));
    }
}
