package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.ArrayList;
import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "면접 세션 생성 Response")
public record InterviewSessionCreateResponse(

        @Schema(
                description = "생성된 면접 세션 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "배정된 질문 목록. 출제 순서대로 정렬됩니다",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewSessionQuestionResponse> questions
) {
    public static InterviewSessionCreateResponse create(
            long sessionId,
            List<Long> answerIds,
            List<SelectedInterviewQuestion> questions
    ) {
        List<InterviewSessionQuestionResponse> questionResponses = new ArrayList<>();

        for (int index = 0; index < answerIds.size(); index++) {
            questionResponses.add(InterviewSessionQuestionResponse.create(
                    answerIds.get(index),
                    index + InterviewAnswer.FIRST_DISPLAY_ORDER,
                    questions.get(index).content()
            ));
        }

        return InterviewSessionCreateResponse.builder()
                .sessionId(sessionId)
                .questions(questionResponses)
                .build();
    }
}
