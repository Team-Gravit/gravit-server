package gravit.code.learning.fixture;

import gravit.code.learning.domain.Learning;
import org.springframework.test.util.ReflectionTestUtils;

public class LearningFixture {

    public static Learning 기본_학습(long userId) {
        Learning learning = Learning.create(userId);
        ReflectionTestUtils.setField(learning, "id", 1L);
        return learning;
    }

    public static Learning 저장된_학습(
            long id,
            long userId
    ) {
        Learning learning = Learning.create(userId);
        ReflectionTestUtils.setField(learning, "id", id);
        return learning;
    }

    public static Learning 저장_전_학습(
            long userId,
            boolean todaySolved,
            int consecutiveDays
    ) {
        Learning learning = Learning.create(userId);
        ReflectionTestUtils.setField(learning, "todaySolved", todaySolved);
        ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", consecutiveDays);
        return learning;
    }

    public static Learning 오늘_학습한_학습(
            long id,
            long userId,
            int consecutiveDays
    ) {
        Learning learning = Learning.create(userId);
        ReflectionTestUtils.setField(learning, "id", id);
        ReflectionTestUtils.setField(learning, "todaySolved", true);
        ReflectionTestUtils.setField(learning, "consecutiveSolvedDays", consecutiveDays);
        return learning;
    }
}
