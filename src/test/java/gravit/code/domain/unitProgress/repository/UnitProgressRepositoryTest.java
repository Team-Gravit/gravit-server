package gravit.code.domain.unitProgress.repository;

import gravit.code.domain.unit.domain.Unit;
import gravit.code.domain.unit.infrastructure.UnitJpaRepository;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.dto.response.UnitInfo;
import gravit.code.domain.unitProgress.infrastructure.UnitProgressJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.annotation.DirtiesContext;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UnitProgressRepositoryTest {

    @Autowired
    private UnitProgressJpaRepository unitProgressRepository;

    @Autowired
    private UnitJpaRepository unitRepository;

    @BeforeEach
    void setUp() {
        Unit unit1 = unitRepository.save(Unit.create("스택", 5L, 1L));
        Unit unit2 = unitRepository.save(Unit.create("큐", 4L, 1L));
        Unit unit3 = unitRepository.save(Unit.create("힙", 6L, 1L));
        Unit unit4 = unitRepository.save(Unit.create("트리", 8L, 1L));

        UnitProgress unitProgress2 = unitProgressRepository.save(
                UnitProgress.create(5L, 1L, unit1.getId())
        );
        unitProgress2.updateCompletedLessons();
        unitProgress2.updateCompletedLessons();
        unitProgress2.updateCompletedLessons();

        UnitProgress unitProgress3 = unitProgressRepository.save(
                UnitProgress.create(4L, 1L, unit2.getId())
        );
        unitProgress3.updateCompletedLessons();
        unitProgress3.updateCompletedLessons();
        unitProgress3.updateCompletedLessons();
        unitProgress3.updateCompletedLessons();

        UnitProgress unitProgress4 = unitProgressRepository.save(
                UnitProgress.create(6L, 1L, unit3.getId())
        );
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
        assertThat(unitProgress.get().getTotalLessons()).isEqualTo(4L);
        assertThat(unitProgress.get().getCompletedLessons()).isEqualTo(4L);
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

    @Test
    @DisplayName("unitId와 userId로 UnitProgress가 존재하는지 조회할 수 있다.")
    void getUnitProgressExistByUnitIdAndUserId1(){
        //given
        Long unitId = 2L;
        Long userId = 1L;

        //when
        boolean exist = unitProgressRepository.existsByUnitIdAndUserId(unitId, userId);

        //then
        assertThat(exist).isTrue();
    }

    @Test
    @DisplayName("unitId와 userId로 UnitProgress가 존재하는지 조회할 수 있다.")
    void getUnitProgressExistByUnitIdAndUserId2(){
        //given
        Long unitId = 2222L;
        Long userId = 1111L;

        //when
        boolean exist = unitProgressRepository.existsByUnitIdAndUserId(unitId, userId);

        //then
        assertThat(exist).isFalse();
    }

    @Test
    @DisplayName("chapterId와 userId로 진행도를 포함한 Unit을 조회할 수 있다.")
    void getUnitInfoWithProgressByChapterIdAndUserId(){
        //given
        Long chapterId = 1L;
        Long userId = 1L;

        //when
        List<UnitInfo> unitInfos = unitProgressRepository.findUnitsWithProgressByChapterId(userId, chapterId);

        //then
        assertThat(unitInfos).hasSize(4);

        assertThat(unitInfos.get(0).unitId()).isEqualTo(1L);
        assertThat(unitInfos.get(0).completedLesson()).isEqualTo(3L);

        assertThat(unitInfos.get(3).unitId()).isEqualTo(4L);
        assertThat(unitInfos.get(3).completedLesson()).isEqualTo(0L);
    }
}