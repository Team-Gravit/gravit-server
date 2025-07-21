package gravit.code.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "유저 레벨 정보 Response(학습 종료 후)")
public record UserLevelResponse(
        Integer level,
        Integer xp
){
    public static UserLevelResponse create(Integer level, Integer xp){
        return UserLevelResponse.builder()
                .level(level)
                .xp(xp)
                .build();
    }
}
