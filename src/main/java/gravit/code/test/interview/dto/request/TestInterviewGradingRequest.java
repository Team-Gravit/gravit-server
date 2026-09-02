package gravit.code.test.interview.dto.request;

import gravit.code.interviewFeedback.dto.internal.InterviewGradingSource;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record TestInterviewGradingRequest(

        @Schema(
                description = "면접 질문 내용",
                example = "퀵 정렬의 동작 방식과 시간복잡도를 설명해주세요."
        )
        @NotBlank
        String question,

        @Schema(description = "핵심 개념 목록")
        @NotEmpty
        @Valid
        List<ConceptRequest> concepts,

        @Schema(
                description = "지원자 답변",
                example = "퀵 정렬은 피벗을 기준으로 작은 값과 큰 값을 나누며 정렬합니다. 평균 시간복잡도는 O(n log n)입니다."
        )
        @NotBlank
        String answer
) {
    public record ConceptRequest(

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

    public InterviewGradingSource toSource() {
        List<InterviewGradingSource.Concept> sourceConcepts = concepts.stream()
                .map(concept -> new InterviewGradingSource.Concept(concept.name(), concept.type()))
                .toList();

        return new InterviewGradingSource(question, sourceConcepts, answer);
    }
}
