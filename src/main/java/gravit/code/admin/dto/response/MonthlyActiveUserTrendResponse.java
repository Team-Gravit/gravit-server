package gravit.code.admin.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record MonthlyActiveUserTrendResponse(

        @Schema(
                description = "월별 활성 유저 수. 요청 구간 전체를 오래된 달부터 연속으로 담고, 활동이 없는 달은 0",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<MonthlyActiveUserPointResponse> points
) {
    public static MonthlyActiveUserTrendResponse of(List<MonthlyActiveUserPointResponse> points) {
        return MonthlyActiveUserTrendResponse.builder()
                .points(points)
                .build();
    }
}
