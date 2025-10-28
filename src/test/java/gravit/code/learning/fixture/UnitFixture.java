package gravit.code.learning.fixture;

import gravit.code.learning.domain.Unit;

public class UnitFixture {

    private static Unit 유닛(
            String name,
            long totalLessons,
            long chapterId
    ) {
        return Unit.create(name, totalLessons, chapterId);
    }

    public static Unit 기본_유닛(long chapterId) {
        return 유닛("유닛이름", 1L, chapterId);
    }
}