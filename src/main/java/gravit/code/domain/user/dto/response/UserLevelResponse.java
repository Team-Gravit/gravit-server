package gravit.code.domain.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "유저 레벨 정보 Response(학습 종료 후)")
public record UserLevelResponse(

        @Schema(
                description = "현재 레벨",
                example = "3"
        )
        Integer currentLevel,

        @Schema(
                description = "다음 레벨",
                example = "4"
        )
        Integer nextLevel,

        @Schema(
                description = "경험치",
                example = "100"
        )
        Integer xp
){
    public static UserLevelResponse create(Integer level, Integer xp){
        return UserLevelResponse.builder()
                .currentLevel(level)
                .nextLevel(level+1)
                .xp(xp)
                .build();
    }
}
