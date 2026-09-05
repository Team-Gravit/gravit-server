package gravit.code.interviewQuestion.dto.response;

import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewConceptResponse(

        @Schema(
                description = "핵심 개념 (판정 가능한 문장 형태)",
                example = "평균 시간복잡도가 O(n log n)임을 언급",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String name,

        @Schema(
                description = "필수/보조 구분",
                example = "ESSENTIAL",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewConceptType type
) {
    public static InterviewConceptResponse from(InterviewQuestionConcept concept) {
        return InterviewConceptResponse.builder()
                .name(concept.getName())
                .type(concept.getType())
                .build();
    }
}
