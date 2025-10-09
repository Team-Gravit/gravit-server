package gravit.code.learning.fixture;

import gravit.code.learning.domain.Unit;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class UnitFixture {

    private final UnitFixtureBuilder unitFixtureBuilder;

    private Unit 유닛_정보(
            String name,
            long totalLessons,
            long chapterId
    ) {
        return unitFixtureBuilder.builder()
                .name(name)
                .totalLessons(totalLessons)
                .chapterId(chapterId)
                .build();
    }

    public Unit 기본_유닛(long chapterId) {
        return 유닛_정보("유닛이름", 1L, chapterId);
    }
}