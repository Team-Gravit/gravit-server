package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewInputType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionQuestionsResponse(

        @Schema(
                description = "면접 세션 아이디",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "답변 입력 방식",
                example = "VOICE",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        InterviewInputType inputType,

        @Schema(
                description = "문항 번호 오름차순으로 정렬된 5문항",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewSessionQuestionResponse> questions
) {
    public static InterviewSessionQuestionsResponse of(
            long sessionId,
            InterviewInputType inputType,
            List<InterviewSessionQuestionResponse> questions
    ) {
        return InterviewSessionQuestionsResponse.builder()
                .sessionId(sessionId)
                .inputType(inputType)
                .questions(questions)
                .build();
    }
}
