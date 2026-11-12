package gravit.code.admin.dto.response;

import gravit.code.answer.domain.Answer;
import gravit.code.option.domain.Option;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record ProblemDetailResponse(

        long problemId,

        long lessonId,

        ProblemType problemType,

        String instruction,

        String content,

        List<ProblemOptionResponse> options,

        ProblemAnswerResponse answer
) {
    public static ProblemDetailResponse objective(
            Problem problem,
            List<Option> options
    ) {
        return ProblemDetailResponse.builder()
                .problemId(problem.getId())
                .lessonId(problem.getLessonId())
                .problemType(problem.getProblemType())
                .instruction(problem.getInstruction())
                .content(problem.getContent())
                .options(options.stream().map(ProblemOptionResponse::from).toList())
                .answer(null)
                .build();
    }

    public static ProblemDetailResponse subjective(
            Problem problem,
            Answer answer
    ) {
        return ProblemDetailResponse.builder()
                .problemId(problem.getId())
                .lessonId(problem.getLessonId())
                .problemType(problem.getProblemType())
                .instruction(problem.getInstruction())
                .content(problem.getContent())
                .options(null)
                .answer(ProblemAnswerResponse.from(answer))
                .build();
    }
}
