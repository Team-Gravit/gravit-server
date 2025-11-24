package gravit.code.problem.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

public record ProblemSubmissionRequest(

        @Schema(
                description = "문제 아이디",
                example = "5"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId,

        @Schema(
                description = "최초 정/오답 여부",
                example = "true"
        )
        @NotNull(message = "최초 정/오답 여부가 비어있습니다.")
        Boolean isCorrect
) {
}
