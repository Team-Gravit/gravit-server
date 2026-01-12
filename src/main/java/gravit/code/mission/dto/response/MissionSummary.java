package gravit.code.mission.dto.response;

import gravit.code.mission.domain.MissionType;
import jakarta.validation.constraints.NotNull;

public record MissionSummary(

        @NotNull
        MissionType missionType,

        boolean isCompleted

) {
}
