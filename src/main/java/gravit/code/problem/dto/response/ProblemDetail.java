package gravit.code.problem.dto.response;

import gravit.code.problem.domain.ProblemType;

public record ProblemDetail(
        long id,
        ProblemType problemType,
        String instruction,
        String content,
        boolean isBookmarked
) {
}
