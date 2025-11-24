//package gravit.code.learning.fixture;
//
//import gravit.code.progress.domain.ChapterProgress;
//import org.springframework.test.util.ReflectionTestUtils;
//
//public class ChapterProgressFixture {
//
//    private static ChapterProgress 챕터_진행도(
//            long totalUnits,
//            long completedUnits,
//            long userId,
//            long chapterId
//    ){
//        ChapterProgress chapterProgress = ChapterProgress.create(totalUnits, userId, chapterId);
//
//        ReflectionTestUtils.setField(chapterProgress, "completedUnits", completedUnits);
//
//        return chapterProgress;
//    }
//
//    public static ChapterProgress 완료된_챕터_진행도(
//            long totalUnits,
//            long userId,
//            long chapterId
//    ) {
//        return 챕터_진행도(totalUnits, totalUnits, userId, chapterId);
//    }
//
//    public static ChapterProgress 완료_직전_챕터_진행도(
//            long totalUnits,
//            long userId,
//            long chapterId
//    ){
//        return 챕터_진행도(totalUnits, totalUnits-1L, userId, chapterId);
//    }
//
//    public static ChapterProgress 일반_챕터_진행도(
//            long totalUnits,
//            long completedUnits,
//            long userId,
//            long chapterId
//    ){
//        return 챕터_진행도(totalUnits, completedUnits, userId, chapterId);
//    }
//
//    public static ChapterProgress 신규_챕터_진행도(
//            long totalUnits,
//            long userId,
//            long chapterId
//    ){
//        return 챕터_진행도(totalUnits, 0L, userId, chapterId);
//    }
//}
//*/
