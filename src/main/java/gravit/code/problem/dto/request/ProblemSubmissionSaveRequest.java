package gravit.code.problem.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

public record ProblemSubmissionSaveRequest(

        @Schema(
                description = "문제 아이디",
                example = "5"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId,

        @Schema(
                description = "최초 정/오답 여부",
                example = "true"
        )
        @NotNull(message = "최초 정/오답 여부가 비어있습니다.")
        Boolean isCorrect,

        @Schema(
                description = "선택한 보기 아이디 (객관식)",
                example = "12"
        )
        Long selectedOptionId,

        @Schema(
                description = "제출한 답안 내용 (주관식)",
                example = "프로세스는 실행 중인 프로그램이다"
        )
        String submittedContent
) {
}
