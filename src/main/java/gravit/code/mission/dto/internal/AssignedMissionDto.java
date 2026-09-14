package gravit.code.mission.dto.internal;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.UserMission;

public record AssignedMissionDto(
        UserMission userMission,

        Mission mission
) {
}
