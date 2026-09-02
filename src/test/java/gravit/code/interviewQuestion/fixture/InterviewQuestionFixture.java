package gravit.code.interviewQuestion.fixture;

import gravit.code.interview.domain.InterviewMode;
import gravit.code.interviewQuestion.domain.InterviewCategory;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewTechStack.domain.InterviewAxis;

import java.util.ArrayList;
import java.util.List;

public class InterviewQuestionFixture {

    private static final long UNIT_ID = 1L;

    public static InterviewCategory 공통CS_카테고리(String name) {
        return InterviewCategory.create(InterviewMode.COMMON_CS, name, null);
    }

    public static InterviewCategory 직무별_카테고리(
            String name,
            InterviewAxis axis
    ) {
        return InterviewCategory.create(InterviewMode.JOB_SPECIFIC, name, axis);
    }

    public static InterviewQuestion 질문(
            long categoryId,
            InterviewDifficulty difficulty
    ) {
        return InterviewQuestion.create(
                categoryId,
                UNIT_ID,
                "카테고리 " + categoryId + "의 " + difficulty + " 질문",
                difficulty
        );
    }

    public static List<InterviewQuestion> 질문_여러개(
            long categoryId,
            InterviewDifficulty difficulty,
            int count
    ) {
        List<InterviewQuestion> questions = new ArrayList<>();

        for (int index = 0; index < count; index++) {
            questions.add(질문(categoryId, difficulty));
        }

        return questions;
    }

    public static List<InterviewQuestion> 난이도별_질문(
            long categoryId,
            int countPerDifficulty
    ) {
        List<InterviewQuestion> questions = new ArrayList<>();

        for (InterviewDifficulty difficulty : InterviewDifficulty.values()) {
            questions.addAll(질문_여러개(categoryId, difficulty, countPerDifficulty));
        }

        return questions;
    }
}
