package gravit.code.admin.dto.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;

public record ReportStatusUpdateRequest(

        @JsonProperty("isResolved")
        @NotNull(message = "isResolved 값은 필수입니다.")
        Boolean isResolved
) {
}
