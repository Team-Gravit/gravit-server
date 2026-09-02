package gravit.code.test.interview.dto.response;

import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgment;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record TestInterviewGradingResponse(

        @Schema(description = "개념별 전달/누락 판정 목록")
        List<ConceptJudgmentResponse> conceptJudgments,

        @Schema(description = "잘못 말한 구간과 교정 문장 목록")
        List<WrongStatementResponse> wrongStatements,

        @Schema(
                description = "결론을 먼저 말했는지 여부 (조리 - 구조성)",
                example = "true"
        )
        boolean conclusionFirst,

        @Schema(
                description = "군더더기 발화 개수 (조리 - 명료성)",
                example = "0"
        )
        int irrelevantStatementCount,

        @Schema(description = "종합 개선 제안")
        String improvementSuggestion
) {
    @Builder(access = AccessLevel.PRIVATE)
    public record ConceptJudgmentResponse(

            @Schema(description = "개념명")
            String conceptName,

            @Schema(
                    description = "전달 여부",
                    example = "true"
            )
            boolean covered,

            @Schema(description = "전달 시 답변 원문의 근거 구간")
            String quote,

            @Schema(description = "누락 시 안내 문구")
            String missingFeedbackText
    ) {
        public static ConceptJudgmentResponse from(InterviewGradingJudgment.ConceptJudgment judgment) {
            return ConceptJudgmentResponse.builder()
                    .conceptName(judgment.conceptName())
                    .covered(judgment.covered())
                    .quote(judgment.quote())
                    .missingFeedbackText(judgment.missingFeedbackText())
                    .build();
        }
    }

    @Builder(access = AccessLevel.PRIVATE)
    public record WrongStatementResponse(

            @Schema(description = "잘못 말한 답변 원문 구간")
            String quotedText,

            @Schema(description = "교정 문장")
            String correctionText
    ) {
        public static WrongStatementResponse from(InterviewGradingJudgment.WrongStatement wrongStatement) {
            return WrongStatementResponse.builder()
                    .quotedText(wrongStatement.quotedText())
                    .correctionText(wrongStatement.correctionText())
                    .build();
        }
    }

    public static TestInterviewGradingResponse from(InterviewGradingJudgment judgment) {
        List<ConceptJudgmentResponse> conceptJudgments = judgment.conceptJudgments().stream()
                .map(ConceptJudgmentResponse::from)
                .toList();

        List<WrongStatementResponse> wrongStatements = judgment.wrongStatements().stream()
                .map(WrongStatementResponse::from)
                .toList();

        return TestInterviewGradingResponse.builder()
                .conceptJudgments(conceptJudgments)
                .wrongStatements(wrongStatements)
                .conclusionFirst(judgment.conclusionFirst())
                .irrelevantStatementCount(judgment.irrelevantStatementCount())
                .improvementSuggestion(judgment.improvementSuggestion())
                .build();
    }
}
