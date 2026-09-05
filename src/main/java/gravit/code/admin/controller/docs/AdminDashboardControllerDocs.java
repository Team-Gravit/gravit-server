package gravit.code.admin.controller.docs;

import gravit.code.admin.dto.response.DailyActiveUserTrendResponse;
import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.dto.response.MonthlyActiveUserTrendResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Admin Dashboard API", description = "백오피스 대시보드")
public interface AdminDashboardControllerDocs {

    @Operation(summary = "대시보드 요약", description = "전체 유저 수, 검수 대기 라벨 수, 미처리 신고 수를 반환합니다.")
    @ApiResponses(@ApiResponse(responseCode = "200", description = "조회 성공"))
    ResponseEntity<DashboardSummaryResponse> getSummary();

    @Operation(
            summary = "일별 활성 유저(DAU) 추이",
            description = "오늘을 포함한 최근 N일의 날짜별 활성 유저 수를 반환합니다. "
                    + "활성은 그날 인증된 요청이 한 번이라도 있었던 유저이고, 활동이 없는 날은 0으로 채워 연속된 구간을 돌려줍니다. "
                    + "이력은 기능 배포 시점부터 쌓이므로 그 이전 날짜는 0입니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "400", description = "days 가 1~365 범위를 벗어남")
    })
    ResponseEntity<DailyActiveUserTrendResponse> getDailyActiveUsers(
            @Parameter(description = "조회할 일수 (1~365)", example = "30")
            @RequestParam(value = "days", defaultValue = "30") @Min(1) @Max(365) int days
    );

    @Operation(
            summary = "월별 활성 유저(MAU) 추이",
            description = "이번 달을 포함한 최근 N개월의 월별 활성 유저 수를 반환합니다. "
                    + "한 유저는 한 달에 한 번만 세고, 활동이 없는 달은 0으로 채워 연속된 구간을 돌려줍니다. "
                    + "이번 달은 월초부터 조회 시점까지의 값이라 inProgress 가 true 로 표시됩니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "조회 성공"),
            @ApiResponse(responseCode = "400", description = "months 가 1~36 범위를 벗어남")
    })
    ResponseEntity<MonthlyActiveUserTrendResponse> getMonthlyActiveUsers(
            @Parameter(description = "조회할 개월 수 (1~36)", example = "12")
            @RequestParam(value = "months", defaultValue = "12") @Min(1) @Max(36) int months
    );
}
