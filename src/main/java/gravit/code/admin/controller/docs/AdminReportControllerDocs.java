package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportSummaryResponse;
import gravit.code.global.exception.domain.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "Admin Report API", description = "관리자 신고 관리 API")
public interface AdminReportControllerDocs {

    @Operation(summary = "신고 목록 조회", description = "페이징된 신고 목록을 조회합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 신고 목록 조회 성공")
    })
    @GetMapping
    ResponseEntity<List<ReportSummaryResponse>> getAllReports(@RequestParam(defaultValue = "0") int page);

    @Operation(summary = "신고 상세 조회", description = "특정 신고의 상세 정보를 조회합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 신고 상세 조회 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 신고 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "신고 조회 실패",
                                            value = "{\"error\" : \"REPORT_4041\", \"message\" : \"신고 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @GetMapping("/{reportId}")
    ResponseEntity<ReportDetailResponse> getReport(@PathVariable Long reportId);

    @Operation(summary = "신고 해결 상태 변경", description = "신고의 해결 상태를 토글합니다<br>" +
            "🔐 <strong>관리자 권한 필요</strong><br>")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "✅ 신고 상태 변경 성공"),
            @ApiResponse(responseCode = "404", description = "🚨 신고 조회 실패",
                    content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE,
                            examples = {
                                    @ExampleObject(
                                            name = "신고 조회 실패",
                                            value = "{\"error\" : \"REPORT_4041\", \"message\" : \"신고 조회에 실패하였습니다.\"}"
                                    )
                            },
                            schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PatchMapping("/{reportId}/status")
    ResponseEntity<Void> updateReportStatus(@PathVariable Long reportId);
}
