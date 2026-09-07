package gravit.code.interview.dto.internal;

import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;
import java.util.Set;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionCreateDto(

        InterviewMode mode,

        InterviewInputType inputType,

        InterviewDifficulty difficulty,

        InterviewStack stack,

        Set<InterviewTopic> topics,

        List<Long> orderedQuestionIds
) {
    public static InterviewSessionCreateDto of(
            InterviewSessionCreateRequest request,
            Set<InterviewTopic> topics,
            List<Long> orderedQuestionIds
    ) {
        return InterviewSessionCreateDto.builder()
                .mode(request.mode())
                .inputType(request.inputType())
                .difficulty(request.difficulty())
                .stack(request.stack())
                .topics(topics)
                .orderedQuestionIds(orderedQuestionIds)
                .build();
    }
}
