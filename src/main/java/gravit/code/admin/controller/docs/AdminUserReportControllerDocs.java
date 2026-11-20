package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.request.ReportStatusUpdateRequest;
import gravit.code.admin.dto.response.UserReportListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.report.domain.UserReportType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;

@Tag(name = "Admin User Report API", description = "백오피스 사용자 신고 관리")
public interface AdminUserReportControllerDocs {

    @Operation(summary = "사용자 신고 목록", description = "reportType·isResolved 필터, 최신순(id DESC). reportedNickname 은 신고 시점 닉네임.")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<PageResponse<UserReportListItemResponse>> getUserReports(
            int page,
            UserReportType reportType,
            Boolean isResolved
    );

    @Operation(summary = "사용자 신고 처리 상태 변경", description = "body 의 isResolved 값으로 명시적 설정(toggle 아님).")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "변경 성공"),
            @ApiResponse(responseCode = "404", description = "존재하지 않는 신고"),
            @ApiResponse(responseCode = "409", description = "미처리로 되돌리려는데 같은 신고자, 대상의 미처리 신고가 이미 있음")
    })
    ResponseEntity<Void> updateStatus(
            Long reportId,
            ReportStatusUpdateRequest request
    );
}
