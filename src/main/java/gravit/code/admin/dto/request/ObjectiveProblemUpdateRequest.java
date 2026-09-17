package gravit.code.admin.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;

import java.util.List;

public record ObjectiveProblemUpdateRequest(

        String instruction,

        String content,

        @Valid
        @Size(min = 4, max = 4, message = "옵션은 정확히 4개여야 합니다.")
        List<ObjectiveOptionUpdateRequest> options
) {
}
