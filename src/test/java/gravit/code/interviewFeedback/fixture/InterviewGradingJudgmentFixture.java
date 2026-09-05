package gravit.code.interviewFeedback.fixture;

import gravit.code.interviewFeedback.domain.InterviewStructureLevel;
import gravit.code.interviewFeedback.dto.internal.InterviewConceptJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;

import java.util.List;

public class InterviewGradingJudgmentFixture {

    private static final String EVIDENCE_SUFFIX = " 근거";
    private static final String SUGGESTION = "**결론을 먼저 말하기**\n\n핵심 결론을 먼저 말한 뒤 부연하면 더 좋습니다.";
    private static final boolean ON_TOPIC = false;
    private static final int NO_IRRELEVANT_STATEMENT = 0;

    public static InterviewConceptJudgmentDto 전달(String name) {
        return new InterviewConceptJudgmentDto(name, name + EVIDENCE_SUFFIX, true);
    }

    public static InterviewConceptJudgmentDto 미전달(String name) {
        return new InterviewConceptJudgmentDto(name, null, false);
    }

    public static InterviewGradingJudgmentDto 판정(
            List<InterviewConceptJudgmentDto> conceptJudgments,
            List<String> wrongConcepts,
            InterviewStructureLevel structureLevel,
            boolean offTopic,
            int irrelevantStatementCount
    ) {
        return new InterviewGradingJudgmentDto(
                conceptJudgments,
                wrongConcepts,
                structureLevel,
                offTopic,
                irrelevantStatementCount,
                SUGGESTION
        );
    }

    public static InterviewGradingJudgmentDto 전달_판정(
            List<InterviewConceptJudgmentDto> conceptJudgments,
            List<String> wrongConcepts
    ) {
        return 판정(conceptJudgments, wrongConcepts, InterviewStructureLevel.CONCLUSION_FIRST, ON_TOPIC, NO_IRRELEVANT_STATEMENT);
    }

    public static InterviewGradingJudgmentDto 전달력_판정(
            List<InterviewConceptJudgmentDto> conceptJudgments,
            InterviewStructureLevel structureLevel,
            boolean offTopic,
            int irrelevantStatementCount
    ) {
        return 판정(conceptJudgments, List.of(), structureLevel, offTopic, irrelevantStatementCount);
    }
}
