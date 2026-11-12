package gravit.code.admin.dto.request;

import jakarta.validation.constraints.NotBlank;

public record StagingLessonUpdateRequest(

        @NotBlank(message = "레슨 제목은 비어있을 수 없습니다.")
        String title
) {
}
