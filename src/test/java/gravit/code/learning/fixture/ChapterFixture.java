package gravit.code.learning.fixture;

import gravit.code.learning.domain.Chapter;
import org.springframework.test.util.ReflectionTestUtils;

public class ChapterFixture {

    private static Chapter 챕터_정보(
            String name,
            String description,
            long totalUnits
    ) {
        Chapter chapter = new Chapter();

        ReflectionTestUtils.setField(chapter, "name", name);
        ReflectionTestUtils.setField(chapter, "description", description);
        ReflectionTestUtils.setField(chapter, "totalUnits", totalUnits);

        return chapter;
    }

    public static Chapter 기본_챕터() {
        return 챕터_정보("챕터이름", "챕터설명", 10L);
    }
}