package gravit.code.domain.lessonProgress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "레슨 정보 DTO")
public record LessonInfo(
        @Schema(
                description = "레슨 아이디",
                example = "1"
        )
        Long lessonId,

        @Schema(
                description = "레슨 이름",
                example = "스택 1/3"
        )
        String lessonName,

        @Schema(
                description = "레슨 완료 여부",
                example = "true"
        )
        boolean isCompleted
) {
}
