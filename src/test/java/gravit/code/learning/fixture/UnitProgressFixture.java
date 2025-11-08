package gravit.code.learning.fixture;

import gravit.code.progress.domain.UnitProgress;
import org.springframework.test.util.ReflectionTestUtils;

public class UnitProgressFixture {

    private static UnitProgress 유닛_진행도(
            long totalLesson,
            long completedLesson,
            long userId,
            long unitId
    ){
        UnitProgress unitProgress = UnitProgress.create(totalLesson, userId, unitId);

        ReflectionTestUtils.setField(unitProgress, "completedLessons", completedLesson);

        return unitProgress;
    }

    public static UnitProgress 완료된_유닛_진행도(
            long totalLesson,
            long userId,
            long unitId
    ){
        return 유닛_진행도(totalLesson, totalLesson, userId, unitId);
    }

    public static UnitProgress 완료_직전_유닛_진행도(
        long totalLesson,
        long userId,
        long unitId
    ){
        return 유닛_진행도(totalLesson, totalLesson-1, userId, unitId);
    }

    public static UnitProgress 일반_유닛_진행도(
            long totalLesson,
            long completedLesson,
            long userId,
            long unitId
    ){
        return 유닛_진행도(totalLesson, completedLesson, userId, unitId);
    }

    public static UnitProgress 신규_유닛_진행도(
            long totalLesson,
            long userId,
            long unitId
    ){
        return 유닛_진행도(totalLesson, 0L, userId, unitId);
    }

}
