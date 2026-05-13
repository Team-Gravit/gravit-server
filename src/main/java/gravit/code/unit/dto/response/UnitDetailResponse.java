package gravit.code.unit.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UnitDetailResponse(
        UnitSummaryResponse unitSummaryResponse,
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
