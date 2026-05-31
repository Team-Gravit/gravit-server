package gravit.code.unit.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record UnitProgressSummaryResponse(
        long unitId,
        String title,
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
    public static UnitProgressSummaryResponse of(
            long unitId,
            String title,
            boolean isCompleted
    ){
        return UnitProgressSummaryResponse.builder()
                .unitId(unitId)
                .title(title)
                .isCompleted(isCompleted)
                .build();
    }
}
