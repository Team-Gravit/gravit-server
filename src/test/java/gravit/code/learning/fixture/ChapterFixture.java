//package gravit.code.learning.fixture;
//
//import gravit.code.learning.domain.Chapter;
//import org.springframework.test.util.ReflectionTestUtils;
//
//public class ChapterFixture {
//
//    private static Chapter 챕터(
//            String title,
//            String description,
//            long totalUnits
//    ) {
//        return Chapter.create(title, description, totalUnits);
//    }
//
//    public static Chapter 기본_챕터() {
//        return 챕터("챕터이름", "챕터설명", 10L);
//    }
//
//    public static Chapter 특정_챕터(
//            String title,
//            String description
//    ){
//        return 챕터(title, description, 10L);
//    }
//
//    public static Chapter 저장된_기본_챕터(
//            long chapterId
//    ){
//        Chapter chapter = 챕터("챕터이름", "챕터설명", 10L);
//
//        ReflectionTestUtils.setField(chapter, "id", chapterId);
//
//        return chapter;
//    }
//}