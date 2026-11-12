package gravit.code.admin.dto.request;

import jakarta.validation.constraints.Size;

public record LessonUpdateRequest(

        @Size(max = 255)
        String title
) {
}
