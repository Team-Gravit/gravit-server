package gravit.code.unitProgress.domain;

import gravit.code.domain.unitProgress.domain.UnitProgress;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UnitProgressTest {

    @DisplayName("유효한 데이터로 유저-유닛 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserUnitProgressWithAvailableData(){

        // given
        Long totalLessons = 3L;
        Long userId = 1L;
        Long unitId = 1L;

        // when
        UnitProgress unitProgress = UnitProgress.create(totalLessons, userId, unitId);

        // then
        assertThat(unitProgress.getTotalLessons()).isEqualTo(totalLessons);
        assertThat(unitProgress.getCompletedLessons()).isZero();
        assertThat(unitProgress.getUserId()).isEqualTo(userId);
        assertThat(unitProgress.getUnitId()).isEqualTo(unitId);
    }
}