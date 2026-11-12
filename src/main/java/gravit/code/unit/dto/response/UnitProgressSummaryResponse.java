package gravit.code.unit.dto.response;

import gravit.code.unit.domain.UnitProgressStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record UnitProgressSummaryResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long unitId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String title,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        UnitProgressStatus status
) {
    public static UnitProgressSummaryResponse of(
            long unitId,
            String title,
            UnitProgressStatus status
    ){
        return UnitProgressSummaryResponse.builder()
                .unitId(unitId)
                .title(title)
                .status(status)
                .build();
    }
}
