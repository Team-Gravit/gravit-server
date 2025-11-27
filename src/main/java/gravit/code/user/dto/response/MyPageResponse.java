package gravit.code.user.dto.response;

import jakarta.validation.constraints.NotNull;

public record MyPageResponse(

        @NotNull
        String nickname,
        int profileImgNumber,
        @NotNull
        String handle,
        long follower,
        long following
) {
}
