package gravit.code.admin.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SubjectiveAnswerUpdateRequest(

        @NotNull(message = "answerId 는 필수입니다.")
        Long answerId,

        @NotBlank(message = "정답 내용은 비어있을 수 없습니다.")
        String content,

        @NotBlank(message = "정답 해설은 비어있을 수 없습니다.")
        String explanation
) {
}
