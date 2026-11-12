package gravit.code.admin.dto.response;

import gravit.code.admin.domain.staging.AnswerStaging;
import gravit.code.admin.domain.staging.OptionStaging;
import gravit.code.admin.domain.staging.ProblemStaging;
import gravit.code.problem.domain.ProblemType;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record StagingProblemResponse(

        long problemId,

        ProblemType problemType,

        String instruction,

        String content,

        List<StagingOptionResponse> options,

        StagingAnswerResponse answer
) {
    public static StagingProblemResponse objective(
            ProblemStaging problem,
            List<OptionStaging> options
    ) {
        return StagingProblemResponse.builder()
                .problemId(problem.getId())
                .problemType(problem.getProblemType())
                .instruction(problem.getInstruction())
                .content(problem.getContent())
                .options(options.stream().map(StagingOptionResponse::from).toList())
                .answer(null)
                .build();
    }

    public static StagingProblemResponse subjective(
            ProblemStaging problem,
            AnswerStaging answer
    ) {
        return StagingProblemResponse.builder()
                .problemId(problem.getId())
                .problemType(problem.getProblemType())
                .instruction(problem.getInstruction())
                .content(problem.getContent())
                .options(null)
                .answer(answer == null ? null : StagingAnswerResponse.from(answer))
                .build();
    }
}
