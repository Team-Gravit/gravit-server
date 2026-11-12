package gravit.code.interviewFeedback.dto.internal;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

@JsonClassDescription("핵심 개념 하나에 대한 전달 판정")
@JsonPropertyOrder({"name", "evidence", "covered"})
public record InterviewConceptJudgmentDto(

        @JsonProperty(required = true)
        @JsonPropertyDescription("핵심 개념 목록의 개념명을 그대로 쓴다")
        String name,

        @JsonPropertyDescription("전달했을 때 근거가 되는 답변 원문 구간을 수정 없이 인용. 전달하지 않았으면 null")
        String evidence,

        @JsonProperty(required = true)
        @JsonPropertyDescription("개념이 뜻하는 내용을 답변이 실제로 설명했으면 true. 키워드만 언급했거나 evidence를 인용할 수 없으면 false")
        boolean covered
) {
}
