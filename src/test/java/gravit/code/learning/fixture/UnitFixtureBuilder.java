package gravit.code.learning.fixture;

import gravit.code.learning.domain.Unit;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.test.util.ReflectionTestUtils;

@TestComponent
public class UnitFixtureBuilder {

    private String name;
    private long totalLessons;
    private long chapterId;

    public UnitFixtureBuilder builder() {
        return new UnitFixtureBuilder();
    }

    public UnitFixtureBuilder name(String name) {
        this.name = name;
        return this;
    }

    public UnitFixtureBuilder totalLessons(long totalLessons) {
        this.totalLessons = totalLessons;
        return this;
    }

    public UnitFixtureBuilder chapterId(long chapterId) {
        this.chapterId = chapterId;
        return this;
    }

    public Unit build() {
        Unit unit = new Unit();

        ReflectionTestUtils.setField(unit, "name", name);
        ReflectionTestUtils.setField(unit, "totalLessons", totalLessons);
        ReflectionTestUtils.setField(unit, "chapterId", chapterId);

        return unit;
    }
}