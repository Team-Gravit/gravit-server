package gravit.code.mission.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record MissionDetail(
        @Schema(
                description = "미션 이름",
                example = "레슨 1개 완료하기"
        )
        String missionDescription,

        @Schema(
                description = "보상 xp",
                example = "40"
        )
        int awardXp,

        @Schema(
                description = "완료 여부",
                example = "false"
        )
        boolean isCompleted
) {
    public static MissionDetail from(MissionSummary missionSummary){
        return MissionDetail.builder()
                .missionDescription(missionSummary.missionType().getDescription())
                .awardXp(missionSummary.missionType().getAwardXp())
                .isCompleted(missionSummary.isCompleted())
                .build();
    }
}
