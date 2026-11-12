package gravit.code.admin.dto.response;

import gravit.code.admin.domain.AdminUser;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record UserDetailResponse(

        long userId,

        String email,

        String nickname,

        String handle,

        int profileImgNumber,

        Role role,

        UserStatus status,

        int level,

        LocalDateTime createdAt
) {
    public static UserDetailResponse from(AdminUser user) {
        return UserDetailResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .nickname(user.getNickname())
                .handle(user.getHandle())
                .profileImgNumber(user.getProfileImgNumber())
                .role(Role.valueOf(user.getRole()))
                .status(UserStatus.valueOf(user.getStatus()))
                .level(user.getLevel())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
