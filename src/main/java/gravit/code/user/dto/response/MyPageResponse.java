package gravit.code.user.dto.response;

import jakarta.validation.constraints.NotNull;

public record MyPageResponse(

        @NotNull
        String nickname,
        @NotNull
        String handle,
        int profileImgNumber,
        long follower,
        long following
) {
}
