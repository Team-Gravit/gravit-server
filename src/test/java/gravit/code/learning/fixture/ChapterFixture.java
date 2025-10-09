package gravit.code.learning.fixture;

import gravit.code.learning.domain.Chapter;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class ChapterFixture {

    private final ChapterFixtureBuilder chapterFixtureBuilder;

    private Chapter 챕터_정보(
            String name,
            String description,
            long totalUnits
    ) {
        return chapterFixtureBuilder.builder()
                .name(name)
                .description(description)
                .totalUnits(totalUnits)
                .build();
    }

    public Chapter 기본_챕터() {
        return 챕터_정보("챕터이름", "챕터설명", 10L);
    }
}