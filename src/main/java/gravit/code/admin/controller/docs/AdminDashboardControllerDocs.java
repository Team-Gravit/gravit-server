package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.response.AdminDashboardSummaryResponse;
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

@Tag(name = "Admin Dashboard API", description = "백오피스 대시보드 관련 API")
public interface AdminDashboardControllerDocs {

    @Operation(
            summary = "대시보드 요약 조회",
            description = """
                    백오피스 대시보드 화면의 위젯 3개에 표시할 카운트를 조회합니다.<br>
                    - totalUsers: DELETED 상태가 아닌 전체 유저 수<br>
                    - pendingLabelsCount: 검수 대기(PENDING) 상태인 스테이징 라벨 수<br>
                    - unresolvedReportsCount: 미처리(isResolved=false) 신고 수<br>
                    🔐 <strong>Jwt 필요 (role=ADMIN)</strong><br>
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "✅ 대시보드 요약 조회 성공",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = AdminDashboardSummaryResponse.class),
                            examples = @ExampleObject(
                                    name = "성공 예시",
                                    value = """
                                            {
                                              "totalUsers": 12345,
                                              "pendingLabelsCount": 8,
                                              "unresolvedReportsCount": 24
                                            }
                                            """
                            )
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "🚨 예기치 못한 예외 발생",
                    content = @Content(
                            mediaType = MediaType.APPLICATION_JSON_VALUE,
                            schema = @Schema(implementation = ErrorResponse.class),
                            examples = @ExampleObject(
                                    name = "예기치 못한 예외 발생",
                                    value = "{\"error\" : \"GLOBAL_5001\", \"message\" : \"예기치 못한 예외 발생\"}"
                            )
                    )
            )
    })
    @GetMapping("/summary")
    ResponseEntity<AdminDashboardSummaryResponse> getDashboardSummary();
}
