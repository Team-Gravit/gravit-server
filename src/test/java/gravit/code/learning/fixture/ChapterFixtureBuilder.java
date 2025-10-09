package gravit.code.learning.fixture;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
@RequiredArgsConstructor
public class ChapterFixtureBuilder {

    private final ChapterRepository chapterRepository;

    private String name;
    private String description;
    private long totalUnits;

    public ChapterFixtureBuilder builder() {
        return new ChapterFixtureBuilder(chapterRepository);
    }

    public ChapterFixtureBuilder name(String name) {
        this.name = name;
        return this;
    }

    public ChapterFixtureBuilder description(String description) {
        this.description = description;
        return this;
    }

    public ChapterFixtureBuilder totalUnits(long totalUnits) {
        this.totalUnits = totalUnits;
        return this;
    }

    public Chapter build() {
        Chapter chapter = new Chapter();

        ReflectionTestUtils.setField(chapter, "name", name);
        ReflectionTestUtils.setField(chapter, "description", description);
        ReflectionTestUtils.setField(chapter, "totalUnits", totalUnits);

        return chapterRepository.save(chapter);
    }
}