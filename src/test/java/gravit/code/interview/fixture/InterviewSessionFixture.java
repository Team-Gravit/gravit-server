package gravit.code.interview.fixture;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.ArrayList;
import java.util.List;

public class InterviewSessionFixture {

    private static final long ATTEMPT_COUNT = 1L;
    private static final int FIRST_DISPLAY_ORDER = 1;

    public static InterviewSession 진행중_세션(
            long userId,
            InterviewInputType inputType
    ) {
        return InterviewSession.create(
                userId,
                ATTEMPT_COUNT,
                InterviewMode.COMMON_CS,
                inputType,
                InterviewDifficulty.NORMAL,
                null
        );
    }

    public static InterviewSession 상태_세션(
            long userId,
            InterviewSessionStatus status
    ) {
        InterviewSession session = 진행중_세션(userId, InterviewInputType.TEXT);
        ReflectionTestUtils.setField(session, "status", status);
        return session;
    }

    public static List<InterviewAnswer> 미제출_답안(
            long sessionId,
            List<Long> questionIds
    ) {
        List<InterviewAnswer> answers = new ArrayList<>();
        for (int index = 0; index < questionIds.size(); index++) {
            answers.add(InterviewAnswer.create(sessionId, questionIds.get(index), FIRST_DISPLAY_ORDER + index));
        }
        return answers;
    }

    public static InterviewAnswerSubmitRequest 답안_요청(
            int displayOrder,
            String content
    ) {
        return new InterviewAnswerSubmitRequest(displayOrder, content, null);
    }

    public static InterviewAnswerSubmitRequest 음성_답안_요청(
            int displayOrder,
            String content,
            String audioKey
    ) {
        return new InterviewAnswerSubmitRequest(displayOrder, content, audioKey);
    }

    public static List<InterviewAnswerSubmitRequest> 제출_요청(String... contents) {
        List<InterviewAnswerSubmitRequest> requests = new ArrayList<>();
        for (int index = 0; index < contents.length; index++) {
            requests.add(답안_요청(FIRST_DISPLAY_ORDER + index, contents[index]));
        }
        return requests;
    }
}
