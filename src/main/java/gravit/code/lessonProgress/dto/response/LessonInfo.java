package gravit.code.lessonProgress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "레슨 정보 DTO")
public record LessonInfo(
        Long lessonId,
        String lessonName,
        boolean isCompleted
) {
}
