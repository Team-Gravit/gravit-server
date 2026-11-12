package gravit.code.friend.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

public record FollowerResponse(

        @Schema(
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long id,

        @Schema(
                example = "김나영",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String nickname,

        @Schema(
                example = "2",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int profileImgNumber,

        @Schema(
                example = "@1235cws",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String handle,

        @JsonProperty("isFollowing")
        @Schema(
                name = "isFollowing",
                description = "내가 해당 팔로워를 팔로우 중인지 여부",
                example = "false",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean isFollowing
) {
}
