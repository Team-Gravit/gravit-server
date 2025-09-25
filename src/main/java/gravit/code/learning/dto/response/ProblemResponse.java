package gravit.code.learning.dto.response;

import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
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
                description = "제목",
                example = "빈칸에 들어갈 단어를 고르시오."
        )
        String question,

        @Schema(
                description = "본문",
                example = "큐에 2, 9, 7, 4를 순차적으로 넣었을 때, 원소 삭제시 반환되는 값은?"
        )
        String content,

        @Schema(
                description = "정답",
                example = "객관식일 경우 option의 order, 주관식일 경우 일반 답안"
        )
        String answer,

        @Schema(
                description = "선지(주관식일 경우 빈 리스트 반환)"
        )
        List<OptionResponse> options

) {
        public static ProblemResponse create(
                Problem problem,
                List<OptionResponse> options
        ) {
                return ProblemResponse.builder()
                        .problemId(problem.getId())
                        .problemType(problem.getProblemType())
                        .question(problem.getQuestion())
                        .content(problem.getContent())
                        .answer(problem.getAnswer())
                        .options(options)
                        .build();
        }
}