package gravit.code.interview.dto.response;

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
                description = "문항 번호 오름차순으로 정렬된 5문항",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewSessionQuestionResponse> questions
) {
    public static InterviewSessionQuestionsResponse of(
            long sessionId,
            List<InterviewSessionQuestionResponse> questions
    ) {
        return InterviewSessionQuestionsResponse.builder()
                .sessionId(sessionId)
                .questions(questions)
                .build();
    }
}
