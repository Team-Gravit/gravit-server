package gravit.code.interviewFeedback.fixture;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewSessionTopic;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interviewFeedback.domain.InterviewFeedback;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class InterviewFeedbackFixture {

    private static final BigDecimal FULL_BASE_RATIO = new BigDecimal("1.000");
    private static final BigDecimal NO_PENALTY_MULTIPLIER = new BigDecimal("1.0");
    private static final int NO_IRRELEVANT_STATEMENT = 0;
    private static final int SESSION_DURATION_MINUTES = 10;

    public static InterviewSession 완료_세션(
            long userId,
            long attemptCount,
            LocalDateTime startedAt,
            int accuracyScore,
            int deliveryScore
    ) {
        InterviewSession session = InterviewSession.create(
                userId,
                attemptCount,
                InterviewMode.COMMON_CS,
                InterviewInputType.TEXT,
                InterviewDifficulty.NORMAL,
                null
        );
        return 완료_상태로(session, startedAt, accuracyScore, deliveryScore);
    }

    public static InterviewSession 직군_완료_세션(
            long userId,
            long attemptCount,
            LocalDateTime startedAt,
            InterviewStack stack,
            int accuracyScore,
            int deliveryScore
    ) {
        InterviewSession session = InterviewSession.create(
                userId,
                attemptCount,
                InterviewMode.JOB_SPECIFIC,
                InterviewInputType.TEXT,
                InterviewDifficulty.NORMAL,
                stack
        );
        return 완료_상태로(session, startedAt, accuracyScore, deliveryScore);
    }

    public static InterviewSession 미완료_세션(
            long userId,
            long attemptCount,
            LocalDateTime startedAt,
            InterviewSessionStatus status
    ) {
        InterviewSession session = InterviewSession.create(
                userId,
                attemptCount,
                InterviewMode.COMMON_CS,
                InterviewInputType.TEXT,
                InterviewDifficulty.NORMAL,
                null
        );
        ReflectionTestUtils.setField(session, "status", status);
        ReflectionTestUtils.setField(session, "startedAt", startedAt);
        return session;
    }

    public static InterviewSessionTopic 세션_주제(
            long sessionId,
            InterviewTopic topic
    ) {
        return InterviewSessionTopic.create(sessionId, topic);
    }

    public static InterviewQuestion 문제(
            InterviewTopic topic,
            long unitId
    ) {
        return InterviewQuestion.create(
                topic,
                unitId,
                InterviewDifficulty.NORMAL,
                topic.getDisplayName() + " 질문",
                topic.getDisplayName() + " 모범답안"
        );
    }

    public static InterviewQuestionConcept 개념(
            long questionId,
            String name,
            InterviewConceptType type,
            int displayOrder
    ) {
        return InterviewQuestionConcept.create(questionId, name, type, displayOrder);
    }

    public static InterviewAnswer 답변한_답안(
            long sessionId,
            long questionId,
            int displayOrder,
            String content,
            LocalDateTime answeredAt
    ) {
        InterviewAnswer answer = InterviewAnswer.create(sessionId, questionId, displayOrder);
        ReflectionTestUtils.setField(answer, "status", InterviewAnswerStatus.ANSWERED);
        ReflectionTestUtils.setField(answer, "content", content);
        ReflectionTestUtils.setField(answer, "answeredAt", answeredAt);
        return answer;
    }

    public static InterviewAnswer 무응답_답안(
            long sessionId,
            long questionId,
            int displayOrder,
            LocalDateTime answeredAt
    ) {
        InterviewAnswer answer = InterviewAnswer.create(sessionId, questionId, displayOrder);
        ReflectionTestUtils.setField(answer, "status", InterviewAnswerStatus.NO_RESPONSE);
        ReflectionTestUtils.setField(answer, "answeredAt", answeredAt);
        return answer;
    }

    public static InterviewFeedback 피드백(
            long answerId,
            int accuracyScore,
            int structureScore,
            int clarityScore,
            String improvementSuggestion
    ) {
        return InterviewFeedback.create(
                answerId,
                accuracyScore,
                structureScore,
                clarityScore,
                FULL_BASE_RATIO,
                NO_PENALTY_MULTIPLIER,
                NO_IRRELEVANT_STATEMENT,
                improvementSuggestion
        );
    }

    public static InterviewFeedback 무응답_피드백(long answerId) {
        return InterviewFeedback.create(answerId, 0, 0, 0, null, null, null, null);
    }

    private static InterviewSession 완료_상태로(
            InterviewSession session,
            LocalDateTime startedAt,
            int accuracyScore,
            int deliveryScore
    ) {
        ReflectionTestUtils.setField(session, "status", InterviewSessionStatus.COMPLETED);
        ReflectionTestUtils.setField(session, "startedAt", startedAt);
        ReflectionTestUtils.setField(session, "endedAt", startedAt.plusMinutes(SESSION_DURATION_MINUTES));
        ReflectionTestUtils.setField(session, "accuracyScore", accuracyScore);
        ReflectionTestUtils.setField(session, "deliveryScore", deliveryScore);
        return session;
    }
}
