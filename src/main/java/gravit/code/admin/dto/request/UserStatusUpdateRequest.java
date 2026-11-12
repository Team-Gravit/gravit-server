package gravit.code.admin.dto.request;

import gravit.code.user.domain.UserStatus;
import jakarta.validation.constraints.NotNull;

public record UserStatusUpdateRequest(

        @NotNull(message = "상태 값은 필수입니다.")
        UserStatus status
) {
}
