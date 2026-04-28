package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserStatus;

import java.time.LocalDateTime;

public record AdminUserDetailResponse(
        long userId,
        String email,
        String nickname,
        String handle,
        int profileImgNumber,
        Role role,
        UserStatus status,
        int level,
        @JsonFormat(pattern = "yyyy-MM-dd") LocalDateTime createdAt
) {
    public static AdminUserDetailResponse of(User user) {
        return new AdminUserDetailResponse(
                user.getId(),
                user.getEmail(),
                user.getNickname(),
                user.getHandle(),
                user.getProfileImgNumber(),
                user.getRole(),
                user.getStatus(),
                user.getLevel().getLevel(),
                user.getCreatedAt()
        );
    }
}
