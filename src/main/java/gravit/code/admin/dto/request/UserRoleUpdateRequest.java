package gravit.code.admin.dto.request;

import gravit.code.user.domain.Role;
import jakarta.validation.constraints.NotNull;

public record UserRoleUpdateRequest(

        @NotNull(message = "권한 값은 필수입니다.")
        Role role
) {
}
