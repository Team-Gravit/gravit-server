package gravit.code.lesson.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record LessonSubmissionSaveRequest(

        @Schema(
                description = "레슨 아이디",
                example = "2"
        )
        @NotNull(message = "레슨 아이디가 비어있습니다.")
        Long lessonId,

        @Schema(
                description = "풀이 시간(단위 : 정수 초) / 1분 20초가 걸렸다면 80",
                example = "80"
        )
        @Min(value = 0, message = "풀이 시간은 0 이하가 될 수 없습니다.")
        @NotNull(message = "풀이 시간이 비어있습니다.")
        Integer learningTime,

        @Schema(
                description = "정확도(단위 : 정수) / 78.9 -> 79",
                example = "79"
        )
        @Min(value = 0, message = "정확도는 0 이하가 될 수 없습니다.")
        @Max(value = 100, message = "정확도는 100 이상이 될 수 없습니다.")
        @NotNull(message = "정확도가 비어있습니다.")
        Integer accuracy

) {
}
