package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "유닛 페이지 조회 Response")
public record UnitDetail(

        @Schema(description = "유닛 요약 정보")
        UnitSummary unitSummaries,

        @Schema(
                description = "진행도(퍼센트)",
                example = "45.6"
        )
        double progressRate
) {
    public static UnitDetail create(
            UnitSummary unitSummaries,
            double progressRate
    ) {
        return UnitDetail.builder()
                .unitSummaries(unitSummaries)
                .progressRate(progressRate)
                .build();
    }
}
