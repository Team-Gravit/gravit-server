package gravit.code.learning.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "문제 정보 Response")
public record ProblemResponse(

        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        long problemId,

        @Schema(
                description = "문제 타입",
                example = "SUBJECTIVE / OBJECTIVE"
        )
        ProblemType problemType,

        @Schema(
                description = "발문",
                example = "빈칸에 들어갈 단어를 고르시오."
        )
        String instruction,

        @Schema(
                description = "본문",
                example = "큐에 2, 9, 7, 4를 순차적으로 넣었을 때, 원소 삭제시 반환되는 값은?"
        )
        String content,

        @Schema(
                description = "주관식 정답"
        )
        @JsonInclude(JsonInclude.Include.NON_NULL)
        AnswerResponse answerResponse,

        @Schema(
                description = "객관식 선지"
        )
        @JsonInclude(JsonInclude.Include.NON_NULL)
        List<OptionResponse> options

) {
        public static ProblemResponse createSubjectiveProblem(
                Problem problem,
                AnswerResponse answerResponse
        ) {
                return ProblemResponse.builder()
                        .problemId(problem.getId())
                        .problemType(problem.getProblemType())
                        .instruction(problem.getInstruction())
                        .content(problem.getContent())
                        .answerResponse(answerResponse)
                        .options(null)
                        .build();
        }

        public static ProblemResponse createObjectiveProblem(
                Problem problem,
                List<OptionResponse> options
        ) {
                return ProblemResponse.builder()
                        .problemId(problem.getId())
                        .problemType(problem.getProblemType())
                        .instruction(problem.getInstruction())
                        .content(problem.getContent())
                        .answerResponse(null)
                        .options(options)
                        .build();
        }
}