package gravit.code.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record MyPageResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String handle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long follower,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long following
) {
}
