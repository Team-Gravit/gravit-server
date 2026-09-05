package gravit.code.admin.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record DailyActiveUserTrendResponse(

        @Schema(
                description = "날짜별 활성 유저 수. 요청 구간 전체를 오래된 날짜부터 연속으로 담고, 활동이 없는 날은 0",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<DailyActiveUserPointResponse> points
) {
    public static DailyActiveUserTrendResponse of(List<DailyActiveUserPointResponse> points) {
        return DailyActiveUserTrendResponse.builder()
                .points(points)
                .build();
    }
}
