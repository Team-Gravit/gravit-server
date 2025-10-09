package gravit.code.learning.fixture;

import gravit.code.learning.domain.Lesson;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class LessonFixture {

    private final LessonFixtureBuilder lessonFixtureBuilder;

    private Lesson 레슨_정보(
            String name,
            long totalProblems,
            long unitId
    ) {
        return lessonFixtureBuilder.builder()
                .name(name)
                .totalProblems(totalProblems)
                .unitId(unitId)
                .build();
    }

    public Lesson 기본_레슨(long unitId) {
        return 레슨_정보("레슨이름", 12L, unitId);
    }
}