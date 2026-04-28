package gravit.code.admin.dto.request;

import gravit.code.global.enums.Enum;
import gravit.code.user.domain.UserStatus;
import jakarta.validation.constraints.NotNull;

public record AdminUserStatusUpdateRequest(
        @NotNull(message = "유저 상태가 비어있습니다.")
        @Enum(target = UserStatus.class, message = "올바르지 않은 유저 상태입니다.")
        UserStatus status
) {
}
