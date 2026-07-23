package gravit.code.mission.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.UserMission;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record MissionDetailResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String missionType,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String missionDescription,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int awardXp,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        double progressRate,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
    public static MissionDetailResponse of(
            Mission mission,
            UserMission userMission
    ) {
        return MissionDetailResponse.builder()
                .missionType(mission.getCode())
                .missionDescription(mission.getTitle())
                .awardXp(mission.getAwardXp())
                .progressRate(mission.calculateProgressRate(userMission.getProgressCount()))
                .isCompleted(userMission.isCompleted())
                .build();
    }
}
