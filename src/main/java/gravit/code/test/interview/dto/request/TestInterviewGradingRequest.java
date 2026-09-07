package gravit.code.test.interview.dto.request;

import gravit.code.interviewFeedback.dto.internal.InterviewGradingConceptDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingInputDto;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record TestInterviewGradingRequest(

        @Schema(
                description = "면접 질문 내용",
                example = "퀵 정렬의 동작 방식과 시간복잡도를 설명해주세요."
        )
        @NotBlank
        String questionContent,

        @Schema(
                description = "모범답안",
                example = "퀵 정렬은 피벗을 기준으로 배열을 분할하고 각 부분을 재귀적으로 정렬합니다. 평균 시간복잡도는 O(n log n), 최악은 O(n^2)입니다."
        )
        @NotBlank
        String modelAnswer,

        @Schema(description = "핵심 개념 목록")
        @NotEmpty
        @Valid
        List<TestInterviewConceptRequest> concepts,

        @Schema(
                description = "지원자 답변 원문",
                example = "퀵 정렬은 피벗을 기준으로 작은 값과 큰 값을 나누며 정렬합니다. 평균 시간복잡도는 O(n log n)입니다."
        )
        @NotBlank
        String answerContent
) {
    public InterviewGradingInputDto toInput() {
        List<InterviewGradingConceptDto> inputConcepts = concepts.stream()
                .map(concept -> new InterviewGradingConceptDto(concept.name(), concept.type()))
                .toList();

        return new InterviewGradingInputDto(questionContent, modelAnswer, inputConcepts, answerContent);
    }
}
