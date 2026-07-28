package gravit.code.lesson.fixture;

import gravit.code.lesson.domain.Lesson;
import org.springframework.test.util.ReflectionTestUtils;

public class LessonFixture {

    public static Lesson 새_레슨(
            String title,
            long unitId
    ) {
        return Lesson.create(title, unitId);
    }

    public static Lesson 기본_레슨(long unitId) {
        Lesson lesson = Lesson.create("프로세스와 스레드", unitId);
        ReflectionTestUtils.setField(lesson, "id", 1L);
        return lesson;
    }

    public static Lesson 저장된_레슨(
            long id,
            long unitId
    ) {
        Lesson lesson = Lesson.create("레슨" + id, unitId);
        ReflectionTestUtils.setField(lesson, "id", id);
        return lesson;
    }

    public static Lesson 저장된_레슨(
            long id,
            String title,
            long unitId
    ) {
        Lesson lesson = Lesson.create(title, unitId);
        ReflectionTestUtils.setField(lesson, "id", id);
        return lesson;
    }
}
