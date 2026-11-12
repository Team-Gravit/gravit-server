package gravit.code.admin.dto.response;

import gravit.code.user.domain.User;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record AdminMeResponse(

        long adminId,

        String nickname,

        String email,

        int profileImgNumber
) {
    public static AdminMeResponse from(User user) {
        return AdminMeResponse.builder()
                .adminId(user.getId())
                .nickname(user.getNickname())
                .email(user.getEmail())
                .profileImgNumber(user.getProfileImgNumber())
                .build();
    }
}
