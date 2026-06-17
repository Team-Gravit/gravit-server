package gravit.code.notification.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record NotificationActor(

        @Schema(
                description = "상대 유저 프로필 ID (= userId)",
                example = "42",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        Long profileId,

        @Schema(
                description = "상대 유저 닉네임",
                example = "홍길동",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String nickname,

        @Schema(
                description = "상대 유저 프로필 이미지 번호",
                example = "2",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int profileImgNumber
) {
}
