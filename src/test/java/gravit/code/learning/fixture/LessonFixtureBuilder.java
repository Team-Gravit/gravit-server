package gravit.code.learning.fixture;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.domain.LessonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
@RequiredArgsConstructor
public class LessonFixtureBuilder {

    private final LessonRepository lessonRepository;

    private String name;
    private long totalProblems;
    private long unitId;

    public LessonFixtureBuilder builder() {
        return new LessonFixtureBuilder(lessonRepository);
    }

    public LessonFixtureBuilder name(String name) {
        this.name = name;
        return this;
    }

    public LessonFixtureBuilder totalProblems(long totalProblems) {
        this.totalProblems = totalProblems;
        return this;
    }

    public LessonFixtureBuilder unitId(long unitId) {
        this.unitId = unitId;
        return this;
    }

    public Lesson build() {
        Lesson lesson = new Lesson();

        ReflectionTestUtils.setField(lesson, "name", name);
        ReflectionTestUtils.setField(lesson, "totalProblems", totalProblems);
        ReflectionTestUtils.setField(lesson, "unitId", unitId);

        return lessonRepository.save(lesson);
    }
}