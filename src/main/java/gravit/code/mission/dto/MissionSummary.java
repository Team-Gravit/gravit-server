package gravit.code.mission.dto;

import gravit.code.mission.domain.MissionType;

public record MissionSummary(
        MissionType missionType,
        boolean isCompleted
) {
}
