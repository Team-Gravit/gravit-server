package gravit.code.learning.fixture;

import gravit.code.learning.domain.Lesson;
import org.springframework.test.util.ReflectionTestUtils;

public class LessonFixture {

    private static Lesson 레슨(
            String name,
            long totalProblems,
            long unitId
    ) {
        Lesson lesson = new Lesson();

        ReflectionTestUtils.setField(lesson, "name", name);
        ReflectionTestUtils.setField(lesson, "totalProblems", totalProblems);
        ReflectionTestUtils.setField(lesson, "unitId", unitId);

        return lesson;
    }

    public static Lesson 기본_레슨(long unitId) {
        return 레슨("레슨이름", 12L, unitId);
    }
}