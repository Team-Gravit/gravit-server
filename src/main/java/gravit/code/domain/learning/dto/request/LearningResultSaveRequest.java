package gravit.code.domain.learning.dto.request;

import gravit.code.domain.problem.dto.request.ProblemResult;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record LearningResultSaveRequest(

        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        @NotNull(message = "챕터 아이디가 비어있습니다.")
        Long chapterId,

        @Schema(
                description = "유닛 아이디",
                example = "2"
        )
        @NotNull(message = "유닛 아이디가 비어있습니다.")
        Long unitId,

        @Schema(
                description = "레슨 아이디",
                example = "2"
        )
        @NotNull(message = "레슨 아이디가 비어있습니다.")
        Long lessonId,

        @Schema(
                description = "각 문제의 풀이 결과"
        )
        @Valid
        List<ProblemResult> problemResults
) {}
