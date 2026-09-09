package gravit.code.interviewQuestion.fixture;

import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.ArrayList;
import java.util.List;

public class InterviewQuestionFixture {

    private static final long UNIT_ID = 11L;
    private static final String ACTIVE_FIELD = "active";

    public static InterviewQuestion 문제(
            InterviewTopic topic,
            InterviewDifficulty difficulty
    ) {
        return 문제(topic, difficulty, UNIT_ID);
    }

    public static InterviewQuestion 문제(
            InterviewTopic topic,
            InterviewDifficulty difficulty,
            long unitId
    ) {
        return InterviewQuestion.create(
                topic,
                unitId,
                difficulty,
                topic.getDisplayName() + " " + difficulty.getDisplayName() + " 질문",
                topic.getDisplayName() + " " + difficulty.getDisplayName() + " 모범답안"
        );
    }

    public static InterviewQuestion 비활성_문제(
            InterviewTopic topic,
            InterviewDifficulty difficulty
    ) {
        InterviewQuestion question = 문제(topic, difficulty, UNIT_ID);
        ReflectionTestUtils.setField(question, ACTIVE_FIELD, false);
        return question;
    }

    public static List<InterviewQuestion> 문제_여러건(
            InterviewTopic topic,
            InterviewDifficulty difficulty,
            int count
    ) {
        List<InterviewQuestion> questions = new ArrayList<>();
        for (int index = 0; index < count; index++) {
            questions.add(문제(topic, difficulty, UNIT_ID));
        }
        return questions;
    }

    public static List<InterviewQuestion> 비활성_문제_여러건(
            InterviewTopic topic,
            InterviewDifficulty difficulty,
            int count
    ) {
        List<InterviewQuestion> questions = new ArrayList<>();
        for (int index = 0; index < count; index++) {
            questions.add(비활성_문제(topic, difficulty));
        }
        return questions;
    }
}
