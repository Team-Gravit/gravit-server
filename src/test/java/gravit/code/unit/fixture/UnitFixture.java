package gravit.code.unit.fixture;

import gravit.code.unit.domain.Unit;
import org.springframework.test.util.ReflectionTestUtils;

public class UnitFixture {

    public static Unit 새_유닛(
            String title,
            long chapterId
    ) {
        return Unit.create(title, title + " 설명", chapterId);
    }

    public static Unit 기본_유닛(long chapterId) {
        Unit unit = Unit.create("프로세스", "프로세스 개념", chapterId);
        ReflectionTestUtils.setField(unit, "id", 1L);
        return unit;
    }

    public static Unit 저장된_유닛(
            long id,
            long chapterId
    ) {
        Unit unit = Unit.create("유닛" + id, "유닛 설명" + id, chapterId);
        ReflectionTestUtils.setField(unit, "id", id);
        return unit;
    }

    public static Unit 저장된_유닛(
            long id,
            String title,
            long chapterId
    ) {
        Unit unit = Unit.create(title, title + " 설명", chapterId);
        ReflectionTestUtils.setField(unit, "id", id);
        return unit;
    }
}
