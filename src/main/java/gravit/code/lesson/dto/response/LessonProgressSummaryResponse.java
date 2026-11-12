package gravit.code.lesson.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 정보 DTO")
public record LessonProgressSummaryResponse(

        @Schema(
                description = "레슨 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long lessonId,

        @Schema(
                description = "레슨 이름",
                example = "스택 1/3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String name,

        @Schema(
                description = "레슨 완료 여부",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
        public static LessonProgressSummaryResponse create(
                long lessonId,
                String name,
                boolean isCompleted
        ) {
                return LessonProgressSummaryResponse.builder()
                        .lessonId(lessonId)
                        .name(name)
                        .isCompleted(isCompleted)
                        .build();
        }
}
