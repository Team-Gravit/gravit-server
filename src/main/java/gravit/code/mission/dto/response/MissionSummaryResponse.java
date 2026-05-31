package gravit.code.mission.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.mission.domain.MissionType;
import jakarta.validation.constraints.NotNull;

public record MissionSummaryResponse(

        @NotNull
        MissionType missionType,
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
}
