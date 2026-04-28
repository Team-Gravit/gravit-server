package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.UserStatus;

import java.time.LocalDateTime;

public record AdminUserSummaryResponse(
        long userId,

        String email,
        String nickname,
        String handle,
        Role role,
        UserStatus status,
        @JsonFormat(pattern = "yyyy-MM-dd")
        LocalDateTime createdAt
) {
}
