package gravit.code.learning.fixture;

import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.LessonProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
@RequiredArgsConstructor
public class LessonProgressFixtureBuilder {

    private final LessonProgressRepository lessonProgressRepository;

    private int attemptCount;
    private int learningTime;
    private boolean isCompleted;
    private long userId;
    private long lessonId;

    public LessonProgressFixtureBuilder builder() {
        return new LessonProgressFixtureBuilder(lessonProgressRepository);
    }

    public LessonProgressFixtureBuilder attemptCount(int attemptCount) {
        this.attemptCount = attemptCount;
        return this;
    }

    public LessonProgressFixtureBuilder learningTime(int learningTime) {
        this.learningTime = learningTime;
        return this;
    }

    public LessonProgressFixtureBuilder isCompleted(boolean isCompleted) {
        this.isCompleted = isCompleted;
        return this;
    }

    public LessonProgressFixtureBuilder userId(long userId) {
        this.userId = userId;
        return this;
    }

    public LessonProgressFixtureBuilder lessonId(long lessonId) {
        this.lessonId = lessonId;
        return this;
    }

    public LessonProgress build() {
        LessonProgress lessonProgress = LessonProgress.create(userId, lessonId);

        ReflectionTestUtils.setField(lessonProgress, "attemptCount", attemptCount);
        ReflectionTestUtils.setField(lessonProgress, "learningTime", learningTime);
        ReflectionTestUtils.setField(lessonProgress, "isCompleted", isCompleted);

        return lessonProgressRepository.save(lessonProgress);
    }
}
