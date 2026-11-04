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

        @Schema(
                description = "미션 진행률 (0~100, 소수점 첫째 자리 반올림). 진행량 / 목표치 x 100, 최대 100",
                example = "33.3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
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
