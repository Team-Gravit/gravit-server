package gravit.code.admin.dto.request;

import gravit.code.global.enums.Enum;
import gravit.code.user.domain.Role;
import jakarta.validation.constraints.NotNull;

public record AdminUserRoleUpdateRequest(
        @NotNull(message = "유저 역할이 비어있습니다.")
        @Enum(target = Role.class, message = "올바르지 않은 유저 역할입니다.")
        Role role
) {
}
