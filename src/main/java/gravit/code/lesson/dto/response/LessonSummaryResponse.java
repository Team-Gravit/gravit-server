package gravit.code.lesson.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "레슨 요약 정보")
public record LessonSummaryResponse(
        @Schema(
                description = "레슨 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long lessonId,

        @Schema(
                description = "레슨 제목",
                example = "스택 1/3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String title,

        @Schema(
                description = "전체 문제 수",
                example = "5",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long totalProblem,

        @Schema(
                description = "해결 여부",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isSolved")
        boolean isSolved
) {
}
