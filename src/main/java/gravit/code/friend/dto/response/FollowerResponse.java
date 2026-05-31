package gravit.code.friend.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

public record FollowerResponse(

        @Schema(example = "1") long id,
        @NotNull @Schema(example = "김나영") String nickname,
        @Schema(example = "2") int profileImgNumber,
        @NotNull @Schema(example = "@1235cws") String handle,
        @JsonProperty("isFollowing")
        @Schema(name = "isFollowing", description = "내가 해당 팔로워를 팔로우 중인지 여부", example = "false")
        boolean isFollowing
) {
}
