//package gravit.code.learning.fixture;
//
//import gravit.code.learning.domain.Learning;
//import org.springframework.test.util.ReflectionTestUtils;
//
//public class LearningFixture {
//
//    private static Learning 학습(
//            long recentChapterId,
//            boolean todaySolved,
//            int consecutiveDays,
//            int planetConquestRate,
//            long userId,
//            long version
//    ) {
//        Learning learning = Learning.create(userId);
//
//        ReflectionTestUtils.setField(learning, "recentChapterId", recentChapterId);
//        ReflectionTestUtils.setField(learning, "todaySolved", todaySolved);
//        ReflectionTestUtils.setField(learning, "consecutiveDays", consecutiveDays);
//        ReflectionTestUtils.setField(learning, "planetConquestRate", planetConquestRate);
//        ReflectionTestUtils.setField(learning, "version", version);
//
//        return learning;
//    }
//
//    public static Learning 기본_학습_정보(long userId) {
//        return 학습(1L, true, 10, 10, userId, 0L);
//    }
//
//    public static Learning 당일_학습_완료(long userId) {
//        return 학습(1L, true, 10, 10, userId, 0L);
//    }
//
//    public static Learning 당일_학습_미완료(long userId) {
//        return 학습(1L, false, 10, 10, userId, 0L);
//    }
//}
