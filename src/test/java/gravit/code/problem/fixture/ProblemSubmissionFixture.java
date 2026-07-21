package gravit.code.problem.fixture;

import gravit.code.problem.domain.ProblemSubmission;
import org.springframework.test.util.ReflectionTestUtils;

public class ProblemSubmissionFixture {

    public static ProblemSubmission 객관식_제출(
            long problemId,
            long userId,
            boolean isCorrect,
            long selectedOptionId
    ) {
        return ProblemSubmission.create(isCorrect, problemId, userId, selectedOptionId, null);
    }

    public static ProblemSubmission 주관식_제출(
            long problemId,
            long userId,
            boolean isCorrect,
            String submittedContent
    ) {
        return ProblemSubmission.create(isCorrect, problemId, userId, null, submittedContent);
    }

    public static ProblemSubmission 저장된_문제_제출(
            long id,
            boolean isCorrect,
            long problemId,
            long userId
    ) {
        ProblemSubmission submission = ProblemSubmission.create(isCorrect, problemId, userId, null, null);
        ReflectionTestUtils.setField(submission, "id", id);
        return submission;
    }
}
