package gravit.code.problem.dto.internal;

import gravit.code.problem.domain.ProblemType;

public record ProblemTypeDto(
        long problemId,

        ProblemType problemType
) {
}
