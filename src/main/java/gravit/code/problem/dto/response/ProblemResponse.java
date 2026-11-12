package gravit.code.problem.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.problem.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "문제 정보 Response")
public record ProblemResponse(

        @Schema(
                description = "문제 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long problemId,

        @Schema(
                description = "문제 타입",
                example = "SUBJECTIVE / OBJECTIVE",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        ProblemType problemType,

        @Schema(
                description = "발문",
                example = "빈칸에 들어갈 단어를 고르시오.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String instruction,

        @Schema(
                description = "본문",
                example = "큐에 2, 9, 7, 4를 순차적으로 넣었을 때, 원소 삭제시 반환되는 값은?",
                requiredMode = Schema.RequiredMode.REQUIRED
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
        List<OptionResponse> options,

        @Schema(
                description = "북마크 여부",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isBookmarked")
        boolean isBookmarked

) {
        public static ProblemResponse createSubjectiveProblem(
                ProblemDetailResponse problemDetailResponse,
                AnswerResponse answerResponse
        ) {
                return ProblemResponse.builder()
                        .problemId(problemDetailResponse.id())
                        .problemType(problemDetailResponse.problemType())
                        .instruction(problemDetailResponse.instruction())
                        .content(problemDetailResponse.content())
                        .answerResponse(answerResponse)
                        .options(null)
                        .isBookmarked(problemDetailResponse.isBookmarked())
                        .build();
        }

        public static ProblemResponse createObjectiveProblem(
                ProblemDetailResponse problemDetailResponse,
                List<OptionResponse> options
        ) {
                return ProblemResponse.builder()
                        .problemId(problemDetailResponse.id())
                        .problemType(problemDetailResponse.problemType())
                        .instruction(problemDetailResponse.instruction())
                        .content(problemDetailResponse.content())
                        .answerResponse(null)
                        .options(options)
                        .isBookmarked(problemDetailResponse.isBookmarked())
                        .build();
        }
}