package gravit.code.test.interview.dto.response;

import gravit.code.interviewFeedback.domain.InterviewStructureLevel;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record TestInterviewGradingResponse(

        @Schema(description = "개념별 전달 판정 목록")
        List<TestInterviewConceptJudgmentResponse> conceptJudgments,

        @Schema(description = "잘못된 개념으로 판정된 답변 원문 구간 목록")
        List<String> wrongConcepts,

        @Schema(
                description = "답변 구성 판정 (구조성). CONCLUSION_FIRST | CONCLUSION_REACHED | UNCLEAR",
                example = "CONCLUSION_FIRST"
        )
        InterviewStructureLevel structureLevel,

        @Schema(
                description = "질문 이탈 여부 (명료성)",
                example = "false"
        )
        boolean offTopic,

        @Schema(
                description = "관계없는 발화 수 (명료성)",
                example = "0"
        )
        int irrelevantStatementCount,

        @Schema(description = "개선 제안 (Markdown)")
        String improvementSuggestion
) {
    public static TestInterviewGradingResponse from(InterviewGradingJudgmentDto judgment) {
        List<TestInterviewConceptJudgmentResponse> conceptJudgments = judgment.conceptJudgments().stream()
                .map(TestInterviewConceptJudgmentResponse::from)
                .toList();

        return TestInterviewGradingResponse.builder()
                .conceptJudgments(conceptJudgments)
                .wrongConcepts(judgment.wrongConcepts())
                .structureLevel(judgment.structureLevel())
                .offTopic(judgment.offTopic())
                .irrelevantStatementCount(judgment.irrelevantStatementCount())
                .improvementSuggestion(judgment.improvementSuggestion())
                .build();
    }
}
