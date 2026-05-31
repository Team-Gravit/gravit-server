package gravit.code.friend.dto.internal;

import com.fasterxml.jackson.annotation.JsonProperty;

public record SearchUserDto(
        long userId,
        int profileImgNumber,
        String nickname,
        String handle,
        @JsonProperty("isFollowing")
        boolean isFollowing
) {
}
