package gravit.code.learning.fixture;

import gravit.code.progress.domain.LessonProgress;
import org.springframework.test.util.ReflectionTestUtils;

public class LessonProgressFixture {

    private static LessonProgress 레슨_진행도(
            int attemptCount,
            int learningTime,
            boolean isCompleted,
            long userId,
            long lessonId
    ) {
        LessonProgress lessonProgress = LessonProgress.create(userId, lessonId);

        ReflectionTestUtils.setField(lessonProgress, "attemptCount", attemptCount);
        ReflectionTestUtils.setField(lessonProgress, "learningTime", learningTime);
        ReflectionTestUtils.setField(lessonProgress, "isCompleted", isCompleted);

        return lessonProgress;
    }

    public static LessonProgress 일반_레슨_진행도(long userId, long lessonId) {
        return 레슨_진행도(1, 180, true, userId, lessonId);
    }

    public static LessonProgress 완료_레슨_진행도(long userId, long lessonId) {
        return 레슨_진행도(2, 180, true, userId, lessonId);
    }
}
