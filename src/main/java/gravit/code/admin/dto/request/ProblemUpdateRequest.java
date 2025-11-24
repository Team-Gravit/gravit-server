package gravit.code.admin.dto.request;

import gravit.code.global.enums.Enum;
import gravit.code.problem.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "문제 수정 Request")
public record ProblemUpdateRequest(
        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId,

        @Schema(
                description = "문제 유형",
                example = "SUBJECTIVE / OBJECTIVE"
        )
        @NotNull(message = "문제 유형이 비어있습니다.")
        @Enum(target = ProblemType.class, message = "유효하지 않은 문제 유형입니다.")
        String problemType,

        @Schema(
                description = "발문",
                example = "빈칸에 들어갈 단어를 고르시오."
        )
        @NotBlank(message = "질문이 비어있습니다.")
        String instruction,

        @Schema(
                description = "본문",
                example = "큐에 2, 9, 7, 4를 순차적으로 넣었을 때, 원소 삭제시 반환되는 값은?"
        )
        @NotBlank(message = "본문이 비어있습니다.")
        String content
) {
}
