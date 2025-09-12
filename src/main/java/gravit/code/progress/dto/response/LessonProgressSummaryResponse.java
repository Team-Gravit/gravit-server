package gravit.code.progress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "레슨 정보 DTO")
public record LessonProgressSummaryResponse(
        @Schema(
                description = "레슨 아이디",
                example = "1"
        )
        Long lessonId,

        @Schema(
                description = "레슨 이름",
                example = "스택 1/3"
        )
        String name,

        @Schema(
                description = "레슨 완료 여부",
                example = "true"
        )
        boolean isCompleted
) {
        public static LessonProgressSummaryResponse create(Long lessonId, String name, boolean isCompleted) {
                return LessonProgressSummaryResponse.builder()
                        .lessonId(lessonId)
                        .name(name)
                        .isCompleted(isCompleted)
                        .build();
        }
}
