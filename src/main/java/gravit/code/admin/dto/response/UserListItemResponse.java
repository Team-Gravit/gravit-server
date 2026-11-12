package gravit.code.admin.dto.response;

import gravit.code.admin.domain.AdminUser;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record UserListItemResponse(

        long userId,

        String email,

        String nickname,

        String handle,

        Role role,

        UserStatus status,

        LocalDateTime createdAt
) {
    public static UserListItemResponse from(AdminUser user) {
        return UserListItemResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .nickname(user.getNickname())
                .handle(user.getHandle())
                .role(Role.valueOf(user.getRole()))
                .status(UserStatus.valueOf(user.getStatus()))
                .createdAt(user.getCreatedAt())
                .build();
    }
}
