package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.ReportStatusUpdateRequest;
import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.report.domain.ReportType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin Report API", description = "백오피스 신고 관리")
public interface AdminReportControllerDocs {

    @Operation(summary = "신고 목록", description = "reportType·isResolved 필터, 최신순(id DESC).")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<ReportListItemResponse>> getReports(
            int page,
            ReportType reportType,
            Boolean isResolved
    );

    @Operation(summary = "신고 상세", description = "신고자(userId)는 미노출.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 신고")
    })
    ResponseEntity<ReportDetailResponse> getReport(Long reportId);

    @Operation(summary = "신고 처리 상태 변경", description = "body 의 isResolved 값으로 명시적 설정(toggle 아님).")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "변경 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 신고")
    })
    ResponseEntity<Void> updateStatus(
            Long reportId,
            ReportStatusUpdateRequest request
    );
}
