package gravit.code.interview.dto.internal;

import java.time.LocalDateTime;

public record InterviewQuestionHistoryDto(

        long questionId,

        LocalDateTime presentedAt,

        Integer accuracyScore
) {
}
