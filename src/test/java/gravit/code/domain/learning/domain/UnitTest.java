package gravit.code.domain.learning.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UnitTest {

    @DisplayName("유효한 데이터로 유닛을 생성할 수 있다")
    @Test
    void createUnitWithAvailableData(){

        // given
        String name = "우선순위 큐";
        Long totalLessons = 3L;
        Long chapterId = 1L;

        // when
        Unit unit = Unit.create(name, totalLessons, chapterId);

        // then
        assertThat(unit.getName()).isEqualTo(name);
        assertThat(unit.getTotalLessons()).isEqualTo(totalLessons);
        assertThat(unit.getChapterId()).isEqualTo(chapterId);
    }

}