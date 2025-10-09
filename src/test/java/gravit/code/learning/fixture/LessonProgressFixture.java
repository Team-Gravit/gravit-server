package gravit.code.learning.fixture;

import gravit.code.progress.domain.LessonProgress;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LessonProgressFixture {

    private final LessonProgressFixtureBuilder lessonProgressFixtureBuilder;

    private LessonProgress 레슨_진행도(
            int attemptCount,
            int learningTime,
            boolean isCompleted,
            long userId,
            long lessonId
    ){
        return lessonProgressFixtureBuilder.builder()
                .attemptCount(attemptCount)
                .learningTime(learningTime)
                .isCompleted(isCompleted)
                .userId(userId)
                .lessonId(lessonId)
                .build();
    }

    public LessonProgress 일반_레슨_진행도(long userId, long lessonId){
        return 레슨_진행도(1, 180, true, userId, lessonId);
    }
}
