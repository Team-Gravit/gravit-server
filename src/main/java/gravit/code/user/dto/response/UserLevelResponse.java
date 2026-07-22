package gravit.code.user.dto.response;

import gravit.code.user.domain.Level;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "유저 레벨 정보 Response(학습 종료 후)")
public record UserLevelResponse(
        @Schema(
                description = "현재 레벨",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int currentLevel,

        @Schema(
                description = "다음 레벨 (최고 레벨이면 현재 레벨과 동일)",
                example = "4",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int nextLevel,

        @Schema(
                description = "경험치",
                example = "100",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int xp
){
    public static UserLevelResponse create(
            int level,
            int xp
    ){
        return UserLevelResponse.builder()
                .currentLevel(level)
                .nextLevel(Level.fromLevel(level).next().getLevel())
                .xp(xp)
                .build();
    }
}
