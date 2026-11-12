package gravit.code.admin.dto.request;

import jakarta.validation.constraints.Size;

public record UnitUpdateRequest(

        @Size(max = 255)
        String title,

        @Size(max = 255)
        String description
) {
}
