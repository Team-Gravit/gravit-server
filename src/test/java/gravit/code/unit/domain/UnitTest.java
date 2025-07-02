package gravit.code.unit.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatNoException;

class UnitTest {

    @DisplayName("유효한 데이터로 유닛을 생성할 수 있다")
    @Test
    void createUnitWithAvailableData(){
        assertThatNoException().isThrownBy(() ->
                Unit.create("우선순위 큐", 3L, 1L));
    }

}