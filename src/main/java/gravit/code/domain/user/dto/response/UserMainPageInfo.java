package gravit.code.domain.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
public record UserMainPageInfo(

        @Schema(
                description = "유저 닉네임",
                example = "땅콩"
        )
        String nickname,

        @Schema(
                description = "유저 레벨",
                example = "4"
        )
        Integer level,

        @Schema(
                description = "유저 경험치",
                example = "100"
        )
        Integer xp
) {
}
