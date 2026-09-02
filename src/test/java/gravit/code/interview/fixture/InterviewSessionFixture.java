package gravit.code.interview.fixture;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;

public class InterviewSessionFixture {

    public static InterviewSession 공통CS_진행중_세션(long userId) {
        return InterviewSession.create(
                userId,
                InterviewMode.COMMON_CS,
                InterviewInputType.TEXT,
                null,
                InterviewLevel.MEDIUM
        );
    }

    public static InterviewAnswer 대기_답변(
            long sessionId,
            long questionId,
            int displayOrder
    ) {
        return InterviewAnswer.createPending(sessionId, questionId, displayOrder);
    }

    public static InterviewSessionCreateRequest 공통CS_생성요청() {
        return new InterviewSessionCreateRequest(
                InterviewMode.COMMON_CS,
                InterviewInputType.TEXT,
                InterviewLevel.MEDIUM,
                null
        );
    }

    public static InterviewSessionCreateRequest 직무별_생성요청(long techStackId) {
        return new InterviewSessionCreateRequest(
                InterviewMode.JOB_SPECIFIC,
                InterviewInputType.TEXT,
                InterviewLevel.MEDIUM,
                techStackId
        );
    }
}
