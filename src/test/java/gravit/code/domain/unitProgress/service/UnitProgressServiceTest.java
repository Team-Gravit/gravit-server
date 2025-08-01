package gravit.code.domain.unitProgress.service;

import gravit.code.domain.unit.domain.Unit;
import gravit.code.domain.unit.domain.UnitRepository;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.domain.UnitProgressRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UnitProgressServiceTest {

    @Mock
    private UnitProgressRepository unitProgressRepository;

    @Mock
    private UnitRepository unitRepository;

    @InjectMocks
    private UnitProgressService unitProgressService;

    @Test
    @DisplayName("UnitProgress를 업데이트할 때, Unit 조회에 실패하면 예외를 반환한다.")
    void throwExceptionWhenUpdateUnitProgressIfFailedAtFindUnit(){
        //given
        Long userId = 1L;
        Long unitId = 1L;

        when(unitRepository.findById(unitId)).thenReturn(Optional.empty());

        //when&then
        assertThatThrownBy(() -> unitProgressService.updateUnitProgress(unitId, userId))
                .isInstanceOf(RestApiException.class)
                .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.UNIT_NOT_FOUND);
    }

    @Test
    @DisplayName("UnitProgress를 업데이트 할때, UnitProgress 조회에 실패하면 새로운 UnitProgress를 생성해 업데이트한 후, 총 레슨수가 2이상이면 false를 반환한다.")
    void createNewUnitProgressWhenUpdateUnitProgressIfFailedAtFindUnitProgress(){
        //given
        Long userId = 1L;
        Long unitId = 1L;
        Long totalLessons = 3L;
        Unit unit = Unit.create("유닛", totalLessons, 1L);
        UnitProgress unitProgress = UnitProgress.create(totalLessons,userId, unitId);

        when(unitRepository.findById(unitId)).thenReturn(Optional.of(unit));
        when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId)).thenReturn(Optional.empty());
        when(unitProgressRepository.save(any(UnitProgress.class))).thenReturn(unitProgress);

        //when
        Boolean result = unitProgressService.updateUnitProgress(unitId, userId);

        //then
        assertThat(result).isFalse();
    }

    @Test
    @DisplayName("UnitProgress를 업데이트할 때, UnitProgress 조회에 성공하면 조회된 UnitProgress를 업데이트한 후, 푼 레슨수와 총 레슨수가 같으면 true를 반환한다.")
    void updateUnitProgressAndReturnTrueWhenTotalLessonsEqualsCompletedLessons(){
        //given
        Long userId = 1L;
        Long unitId = 1L;
        Long totalLessons = 2L;
        Unit unit = Unit.create("유닛", totalLessons, 1L);
        UnitProgress unitProgress = UnitProgress.create(totalLessons,userId, unitId);
        unitProgress.updateCompletedLessons();

        when(unitRepository.findById(unitId)).thenReturn(Optional.of(unit));
        when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId)).thenReturn(Optional.of(unitProgress));
        when(unitProgressRepository.save(any(UnitProgress.class))).thenReturn(unitProgress);

        //when
        Boolean result = unitProgressService.updateUnitProgress(unitId, userId);

        //then
        assertThat(result).isTrue();
    }
}