package gravit.code.interview.dto.response;

import gravit.code.interview.dto.internal.InterviewSessionQuestionDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionQuestionResponse(

        @Schema(
                description = "문항 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "문제 본문",
                example = "퀵 정렬의 동작 방식과 평균 시간복잡도를 설명해 주세요.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String content
) {
    public static InterviewSessionQuestionResponse from(InterviewSessionQuestionDto question) {
        return InterviewSessionQuestionResponse.builder()
                .displayOrder(question.displayOrder())
                .content(question.content())
                .build();
    }
}
