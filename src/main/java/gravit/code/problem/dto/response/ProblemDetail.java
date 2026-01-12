package gravit.code.problem.dto.response;

import gravit.code.problem.domain.ProblemType;
import jakarta.validation.constraints.NotNull;

public record ProblemDetail(

        long id,

        @NotNull
        ProblemType problemType,

        @NotNull
        String instruction,

        @NotNull
        String content,

        boolean isBookmarked
) {
}
