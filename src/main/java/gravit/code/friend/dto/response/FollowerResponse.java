package gravit.code.friend.dto.response;

import jakarta.validation.constraints.NotNull;

public record FollowerResponse(

        long id,
        @NotNull
        String nickname,
        int profileImgNumber,
        @NotNull
        String handle
) {
}
