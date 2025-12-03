package gravit.code.user.dto.response;

import jakarta.validation.constraints.NotNull;

public record MyPageResponse(
        String nickname,
        int profileImgNumber,
        String handle,
        long follower,
        long following
) {
}
