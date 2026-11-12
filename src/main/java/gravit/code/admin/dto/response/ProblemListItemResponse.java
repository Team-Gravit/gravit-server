package gravit.code.admin.dto.response;

import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ProblemListItemResponse(

        long problemId,

        ProblemType problemType,

        String instruction
) {
    public static ProblemListItemResponse from(Problem problem) {
        return ProblemListItemResponse.builder()
                .problemId(problem.getId())
                .problemType(problem.getProblemType())
                .instruction(problem.getInstruction())
                .build();
    }
}
