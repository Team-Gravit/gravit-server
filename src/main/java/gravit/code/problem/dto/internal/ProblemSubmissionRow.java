package gravit.code.problem.dto.internal;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;

public record ProblemSubmissionRow(

        @JsonProperty("problem_id")
        long problemId,

        @JsonProperty("is_correct")
        boolean isCorrect,

        @JsonProperty("selected_option_id")
        Long selectedOptionId,

        @JsonProperty("submitted_content")
        String submittedContent
) {
    public static ProblemSubmissionRow from(ProblemSubmissionSaveRequest request) {
        return new ProblemSubmissionRow(
                request.problemId(),
                request.isCorrect(),
                request.selectedOptionId(),
                request.submittedContent()
        );
    }
}
