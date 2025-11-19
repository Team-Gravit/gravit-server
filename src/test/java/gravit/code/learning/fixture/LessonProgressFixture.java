//package gravit.code.learning.fixture;
//
//import gravit.code.learning.domain.LessonSubmission;
//import org.springframework.test.util.ReflectionTestUtils;
//
//public class LessonProgressFixture {
//
//    private static LessonSubmission 레슨_진행도(
//            int attemptCount,
//            int learningTime,
//            boolean isCompleted,
//            long userId,
//            long lessonId
//    ) {
//        LessonSubmission lessonProgress = LessonSubmission.create(userId, lessonId);
//
//        ReflectionTestUtils.setField(lessonProgress, "attemptCount", attemptCount);
//        ReflectionTestUtils.setField(lessonProgress, "learningTime", learningTime);
//        ReflectionTestUtils.setField(lessonProgress, "isCompleted", isCompleted);
//
//        return lessonProgress;
//    }
//
//    public static LessonSubmission 일반_레슨_진행도(
//            long userId,
//            long lessonId
//    ) {
//        return 레슨_진행도(1, 180, true, userId, lessonId);
//    }
//
//    public static LessonSubmission 완료_레슨_진행도(
//            long userId,
//            long lessonId
//    ) {
//        return 레슨_진행도(2, 180, true, userId, lessonId);
//    }
//
//    public static LessonSubmission 미완료_레슨_진행도(
//            long userId,
//            long lessonId
//    ) {
//        return 레슨_진행도(2, 180, false, userId, lessonId);
//    }
//}
