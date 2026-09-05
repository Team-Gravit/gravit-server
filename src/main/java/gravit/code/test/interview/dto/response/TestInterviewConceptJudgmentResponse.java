package gravit.code.test.interview.dto.response;

import gravit.code.interviewFeedback.dto.internal.InterviewConceptJudgmentDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record TestInterviewConceptJudgmentResponse(

        @Schema(description = "개념명")
        String name,

        @Schema(description = "전달 시 답변 원문의 근거 구간")
        String evidence,

        @Schema(
                description = "전달 여부",
                example = "true"
        )
        boolean covered
) {
    public static TestInterviewConceptJudgmentResponse from(InterviewConceptJudgmentDto judgment) {
        return TestInterviewConceptJudgmentResponse.builder()
                .name(judgment.name())
                .evidence(judgment.evidence())
                .covered(judgment.covered())
                .build();
    }
}
