package gravit.code.unit.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UnitDetailResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        UnitSummaryResponse unitSummaryResponse,

        @Schema(
                description = "유닛 진행률 (0~100, 소수점 버림). 푼 레슨 수 / 유닛 전체 레슨 수 x 100",
                example = "33.0",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        double progressRate
) {
    public static UnitDetailResponse create(
            UnitSummaryResponse unitSummaryResponse,
            double progressRate
    ) {
        return UnitDetailResponse.builder()
                .unitSummaryResponse(unitSummaryResponse)
                .progressRate(progressRate)
                .build();
    }
}
