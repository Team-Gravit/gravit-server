package gravit.code.problem.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
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
        @NotNull
        ProblemType problemType,

        @Schema(
                description = "발문",
                example = "빈칸에 들어갈 단어를 고르시오."
        )
        @NotNull
        String instruction,

        @Schema(
                description = "본문",
                example = "큐에 2, 9, 7, 4를 순차적으로 넣었을 때, 원소 삭제시 반환되는 값은?"
        )
        @NotNull
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
        List<OptionResponse> options,

        @Schema(
                description = "북마크 여부",
                example = "true"
        )
        boolean isBookmarked

) {
        public static ProblemResponse createSubjectiveProblem(
                ProblemDetail problemDetail,
                AnswerResponse answerResponse
        ) {
                return ProblemResponse.builder()
                        .problemId(problemDetail.id())
                        .problemType(problemDetail.problemType())
                        .instruction(problemDetail.instruction())
                        .content(problemDetail.content())
                        .answerResponse(answerResponse)
                        .options(null)
                        .isBookmarked(problemDetail.isBookmarked())
                        .build();
        }

        public static ProblemResponse createObjectiveProblem(
                ProblemDetail problemDetail,
                List<OptionResponse> options
        ) {
                return ProblemResponse.builder()
                        .problemId(problemDetail.id())
                        .problemType(problemDetail.problemType())
                        .instruction(problemDetail.instruction())
                        .content(problemDetail.content())
                        .answerResponse(null)
                        .options(options)
                        .isBookmarked(problemDetail.isBookmarked())
                        .build();
        }

        public static ProblemResponse createSubjectiveProblemForAdmin(
                Problem problem,
                AnswerResponse answerResponse
        ){
                return ProblemResponse.builder()
                        .problemId(problem.getId())
                        .problemType(problem.getProblemType())
                        .instruction(problem.getInstruction())
                        .content(problem.getContent())
                        .answerResponse(answerResponse)
                        .options(null)
                        .isBookmarked(false)
                        .build();
        }

        public static ProblemResponse createObjectiveProblemForAdmin(
                Problem problem,
                List<OptionResponse> options
        ){
                return ProblemResponse.builder()
                        .problemId(problem.getId())
                        .problemType(problem.getProblemType())
                        .instruction(problem.getInstruction())
                        .content(problem.getContent())
                        .answerResponse(null)
                        .options(options)
                        .isBookmarked(false)
                        .build();
        }
}