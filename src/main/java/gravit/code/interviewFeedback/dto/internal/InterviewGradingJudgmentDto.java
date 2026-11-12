package gravit.code.interviewFeedback.dto.internal;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import gravit.code.interviewFeedback.domain.InterviewStructureLevel;

import java.util.List;

@JsonClassDescription("면접 답변 하나에 대한 판정 결과")
@JsonPropertyOrder({
        "conceptJudgments",
        "wrongConcepts",
        "structureLevel",
        "offTopic",
        "irrelevantStatementCount",
        "improvementSuggestion"
})
public record InterviewGradingJudgmentDto(

        @JsonProperty(required = true)
        @JsonPropertyDescription("핵심 개념 목록의 개념마다 하나씩, 목록 순서대로. 하나도 빠뜨리지 않는다")
        List<InterviewConceptJudgmentDto> conceptJudgments,

        @JsonProperty(required = true)
        @JsonPropertyDescription("사실과 명백히 다르게 말한 답변 원문 구간을 수정 없이 인용한 목록. 없으면 빈 배열")
        List<String> wrongConcepts,

        @JsonProperty(required = true)
        @JsonPropertyDescription("답변 구성. CONCLUSION_FIRST: 결론을 먼저 말한 뒤 부연 / CONCLUSION_REACHED: 부연이 앞서지만 결론 도달 / UNCLEAR: 결론이 없거나 나열식")
        InterviewStructureLevel structureLevel,

        @JsonProperty(required = true)
        @JsonPropertyDescription("답변 전체가 질문과 다른 주제를 다루면 true. 일부 군더더기는 이탈이 아니다")
        boolean offTopic,

        @JsonProperty(required = true)
        @JsonPropertyDescription("질문과 무관하거나 불필요하게 반복한 문장 수. 없으면 0")
        int irrelevantStatementCount,

        @JsonProperty(required = true)
        @JsonPropertyDescription("Markdown 개선 제안, 한국어 존댓말. 개선할 점이 없으면 답변을 인정하고 격려하는 한 문장만. 있으면 최대 2개, 항목은 굵은 제목 한 줄 + 빈 줄 + 설명 한 단락이고 항목 사이는 <br> 한 줄. 굵게는 제목에만 쓴다")
        String improvementSuggestion
) {
}
