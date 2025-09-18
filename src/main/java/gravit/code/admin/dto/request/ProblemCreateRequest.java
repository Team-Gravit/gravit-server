package gravit.code.admin.dto.request;

import gravit.code.global.enums.Enum;
import gravit.code.learning.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

@Schema(description = "문제 생성 Request")
public record ProblemCreateRequest(

        @Schema(
                description = "레슨 아이디",
                example = "3"
        )
        @NotNull(message = "레슨 아이디가 비어있습니다.")
        Long lessonId,

        @Schema(
                description = "문제 유형",
                example = "SUBJECTIVE/OBJECTIVE"
        )
        @NotNull(message = "문제 유형이 비어있습니다.")
        @Enum(target = ProblemType.class, message = "올바르지 않은 문제 유형입니다.")
        String problemType,

        @Schema(
                description = "질문",
                example = "빈칸에 들어갈 말로 알맞은 것을 고르시오"
        )
        @NotBlank(message = "문제 질문이 비어있습니다.")
        String question,

        @Schema(
                description = "본문",
                example = "큐에 2, 9, 7, 4를 순차적으로 넣었을 때, 원소 삭제시 반환되는 값은?"
        )
        @NotBlank(message = "본문이 비어있습니다.")
        String content,

        @Schema(
                description = "정답(주관식일 떄만. 객관식일때는 -)",
                example = "2"
        )
        @NotBlank(message = "정답이 비어있습니다.")
        String answer,

        @Schema(
                description = "선지"
        )
        List<OptionCreateRequest> options
) {
}
