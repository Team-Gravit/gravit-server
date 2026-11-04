package gravit.code.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UserLevelDetailResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int level,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int currentXp,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int maxXp,

        @Schema(
                description = "현재 레벨 진행률 (0~100, 소수점 첫째 자리 반올림). 현재 레벨 구간에서 획득한 XP / 구간 XP x 100, 최대 레벨이면 100",
                example = "31.3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        double levelRate
) {
    public static UserLevelDetailResponse of(
            int level,
            int currentXp,
            int maxXp,
            double levelRate
    ) {
        return UserLevelDetailResponse.builder()
                .level(level)
                .currentXp(currentXp)
                .maxXp(maxXp)
                .levelRate(levelRate)
                .build();
    }
}
