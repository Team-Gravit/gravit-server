package gravit.code.friend.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;

public record FollowerResponse(

        long id,
        @NotNull
        String nickname,
        int profileImgNumber,
        @NotNull
        String handle,
        @JsonProperty("isFollowing")
        boolean isFollowing
) {
}
