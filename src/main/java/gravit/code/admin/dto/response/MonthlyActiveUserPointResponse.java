package gravit.code.admin.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record MonthlyActiveUserPointResponse(

        @Schema(
                description = "연월 (yyyy-MM)",
                example = "2026-09",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String month,

        @Schema(
                description = "해당 달의 활성 유저 수 (한 유저는 한 번만 센다)",
                example = "310",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long mau,

        @Schema(
                description = "진행 중인 달 여부. true 면 월초부터 조회 시점까지의 값이라 지난 달과 같은 기준으로 비교하면 안 된다",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean inProgress
) {
    public static MonthlyActiveUserPointResponse of(
            String month,
            long mau,
            boolean inProgress
    ) {
        return MonthlyActiveUserPointResponse.builder()
                .month(month)
                .mau(mau)
                .inProgress(inProgress)
                .build();
    }
}
