package gravit.code.learning.fixture;

import gravit.code.learning.domain.Lesson;

public class LessonFixture {

    private static Lesson 레슨(
            String name,
            long totalProblems,
            long unitId
    ) {
        return Lesson.create(name, totalProblems, unitId);
    }

    public static Lesson 기본_레슨(long unitId) {
        return 레슨("레슨이름", 12L, unitId);
    }
}