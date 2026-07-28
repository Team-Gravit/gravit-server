package gravit.code.chapter.fixture;

import gravit.code.chapter.domain.Chapter;
import org.springframework.test.util.ReflectionTestUtils;

public class ChapterFixture {

    public static Chapter 새_챕터(String title) {
        return Chapter.create(title, title + " 설명");
    }

    public static Chapter 기본_챕터() {
        Chapter chapter = Chapter.create("운영체제", "운영체제 기초 개념");
        ReflectionTestUtils.setField(chapter, "id", 1L);
        return chapter;
    }

    public static Chapter 저장된_챕터(long id) {
        Chapter chapter = Chapter.create("챕터" + id, "챕터 설명" + id);
        ReflectionTestUtils.setField(chapter, "id", id);
        return chapter;
    }

    public static Chapter 저장된_챕터(
            long id,
            String title
    ) {
        Chapter chapter = Chapter.create(title, title + " 설명");
        ReflectionTestUtils.setField(chapter, "id", id);
        return chapter;
    }
}
