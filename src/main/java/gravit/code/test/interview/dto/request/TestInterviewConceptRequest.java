package gravit.code.test.interview.dto.request;

import gravit.code.interviewQuestion.domain.InterviewConceptType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record TestInterviewConceptRequest(

        @Schema(
                description = "판정 가능한 문장으로 작성된 개념명",
                example = "평균 시간복잡도가 O(n log n)임을 언급"
        )
        @NotBlank
        String name,

        @Schema(
                description = "필수/보조 구분",
                example = "ESSENTIAL"
        )
        @NotNull
        InterviewConceptType type
) {
}
