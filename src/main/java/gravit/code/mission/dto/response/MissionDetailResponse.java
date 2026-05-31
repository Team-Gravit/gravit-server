package gravit.code.mission.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.mission.domain.Mission;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record MissionDetailResponse(
        String missionType,
        String missionDescription,
        int awardXp,
        double progressRate,
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
    public static MissionDetailResponse from(Mission mission) {
        return MissionDetailResponse.builder()
                .missionType(mission.getMissionType().name())
                .missionDescription(mission.getMissionType().getDescription())
                .awardXp(mission.getMissionType().getAwardXp())
                .progressRate(mission.getProgressRate())
                .isCompleted(mission.isCompleted())
                .build();
    }
}