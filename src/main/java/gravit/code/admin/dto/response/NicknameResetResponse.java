package gravit.code.admin.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record NicknameResetResponse(

        long userId,

        String nickname
) {
    public static NicknameResetResponse of(
            long userId,
            String nickname
    ) {
        return NicknameResetResponse.builder()
                .userId(userId)
                .nickname(nickname)
                .build();
    }
}
