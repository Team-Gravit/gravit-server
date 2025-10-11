package gravit.code.learning.fixture;

import gravit.code.learning.domain.Unit;
import org.springframework.test.util.ReflectionTestUtils;

public class UnitFixture {

    private static Unit 유닛(
            String name,
            long totalLessons,
            long chapterId
    ) {
        Unit unit = new Unit();

        ReflectionTestUtils.setField(unit, "name", name);
        ReflectionTestUtils.setField(unit, "totalLessons", totalLessons);
        ReflectionTestUtils.setField(unit, "chapterId", chapterId);

        return unit;
    }

    public static Unit 기본_유닛(long chapterId) {
        return 유닛("유닛이름", 1L, chapterId);
    }
}