package gravit.code.interview.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "면접 세션에 배정된 질문 Response")
public record InterviewSessionQuestionResponse(

        @Schema(
                description = "답변 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long answerId,

        @Schema(
                description = "출제 순서",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "질문 본문",
                example = "인덱스가 무엇인지 설명해주세요.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String content
) {
    public static InterviewSessionQuestionResponse create(
            long answerId,
            int displayOrder,
            String content
    ) {
        return InterviewSessionQuestionResponse.builder()
                .answerId(answerId)
                .displayOrder(displayOrder)
                .content(content)
                .build();
    }
}
