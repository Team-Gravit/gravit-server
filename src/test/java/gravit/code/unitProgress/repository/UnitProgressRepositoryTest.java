package gravit.code.unitProgress.repository;

import gravit.code.unitProgress.domain.UnitProgress;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UnitProgressRepositoryTest {

    @Autowired
    private UnitProgressRepository unitProgressRepository;

    @BeforeEach
    void setUp() {
        UnitProgress unitProgress = UnitProgress.create(
                3L,
                1L,
                2L
        );
        unitProgressRepository.save(unitProgress);
    }

    @Test
    @DisplayName("unitId와 userId를 통해 UnitProgress를 조회할 수 있다.")
    void getUnitProgressByUnitIdAndUserId(){
        // given
        Long unitId = 2L;
        Long userId = 1L;

        // when
        Optional<UnitProgress> unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId, userId);

        // then
        assertThat(unitProgress).isPresent();
        assertThat(unitProgress.get().getUnitId()).isEqualTo(unitId);
        assertThat(unitProgress.get().getUserId()).isEqualTo(userId);
        assertThat(unitProgress.get().getTotalLessons()).isEqualTo(3L);
        assertThat(unitProgress.get().getCompletedLessons()).isZero();
    }

    @Test
    @DisplayName("존재하지 않는 unitId와 userId를 통해 UnitProgress를 조회하면 null을 반환한다.")
    void getUnitProgressByNonExistUnitIdAndUserId(){
        // given
        Long unitId = 222222L;
        Long userId = 111111L;

        // when
        Optional<UnitProgress> unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId, userId);

        // then
        assertThat(unitProgress).isNotPresent();
    }
}