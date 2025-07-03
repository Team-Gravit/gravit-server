package gravit.code.userUnitProgress.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserUnitProgressTest {

    @DisplayName("유효한 데이터로 유저-유닛 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserUnitProgressWithAvailableData(){

        // given
        Long userId = 1L;
        Long unitId = 1L;

        // when
        UserUnitProgress userUnitProgress = UserUnitProgress.create(userId, unitId);

        // then
        assertThat(userUnitProgress.getCompletedLessons()).isEqualTo(0L);
        assertThat(userUnitProgress.getUserId()).isEqualTo(userId);
        assertThat(userUnitProgress.getUnitId()).isEqualTo(unitId);
    }
}