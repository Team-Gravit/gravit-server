package gravit.code.admin.dto.request;

import gravit.code.admin.domain.staging.LabelStatus;
import jakarta.validation.constraints.NotNull;

public record LabelStatusUpdateRequest(

        @NotNull(message = "상태 값은 필수입니다.")
        LabelStatus status
) {
}
