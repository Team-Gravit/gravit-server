package gravit.code.interviewQuestion.dto.internal;

import gravit.code.interviewQuestion.domain.InterviewDifficulty;

public record InterviewQuestionPoolItem(
        long questionId,
        long categoryId,
        InterviewDifficulty difficulty
) {
}
