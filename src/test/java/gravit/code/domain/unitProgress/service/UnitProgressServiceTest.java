package gravit.code.domain.unitProgress.service;

import gravit.code.domain.unit.domain.UnitRepository;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.domain.UnitProgressRepository;
import gravit.code.domain.unitProgress.service.UnitProgressService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UnitProgressServiceTest {

    @Mock
    private UnitProgressRepository unitProgressRepository;

    @Mock
    private UnitRepository unitRepository;

    @InjectMocks
    private UnitProgressService unitProgressService;

    @Test
    @DisplayName("UnitProgress를 업데이트한 후, ChapterProgress를 업데이트해야 하면 True를 반환한다.")
    void updateLessonProgressAndReturnTrueWhenChapterProgressUpdateNeeded(){
        // given
        Long unitId = 1L;
        Long userId = 1L;
        UnitProgress expectedUnitProgress = UnitProgress.create(1L, 1L, 1L);

        when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId)).thenReturn(Optional.ofNullable(expectedUnitProgress));

        // when
        Boolean chapterProgressUpdatedNeeded = unitProgressService.updateUnitProgress(unitId, userId);

        // then
        assertThat(chapterProgressUpdatedNeeded).isTrue();
    }

    @Test
    @DisplayName("UnitProgress를 업데이트한 후, ChapterProgress를 업데이트가 필요하지 않으면 False를 반환한다.")
    void updateLessonProgressAndReturnFalseWhenChapterProgressUpdateIsNotNeeded(){
        // given
        Long unitId = 1L;
        Long userId = 1L;
        UnitProgress expectedUnitProgress = UnitProgress.create(3L, 1L, 1L);

        when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId)).thenReturn(Optional.ofNullable(expectedUnitProgress));

        // when
        Boolean chapterProgressUpdatedNeeded = unitProgressService.updateUnitProgress(unitId, userId);

        // then
        assertThat(chapterProgressUpdatedNeeded).isFalse();
    }

    @Test
    @DisplayName("userId와 unitId로 UnitProgress를 조회한 경우 존재한다면, false를 반환한다.")
    void createNoUnitProgressIfExistAndReturnFalse(){
        //given
        Long userId = 1L;
        Long unitId = 1L;

        when(unitProgressRepository.existsByUnitIdAndUserId(unitId, userId)).thenReturn(true);

        //when
        Boolean result = unitProgressService.createUnitProgress(userId, unitId);

        //then
        assertThat(result).isFalse();
        verify(unitRepository, never()).getTotalLessonsByUnitId(unitId);
        verify(unitProgressRepository, never()).save(any(UnitProgress.class));
    }

    @Test
    @DisplayName("userId와 unitId로 UnitProgress를 조회한 경우 존재하지 않는다면 생성하고, true를 반환한다. ")
    void createUnitProgressIfNotExistAndReturnTrue(){
        //given
        Long userId = 1L;
        Long unitId = 1L;

        when(unitProgressRepository.existsByUnitIdAndUserId(unitId, userId)).thenReturn(false);
        when(unitRepository.getTotalLessonsByUnitId(unitId)).thenReturn(10L);
        //when
        Boolean result = unitProgressService.createUnitProgress(userId, unitId);

        //then
        assertThat(result).isTrue();
        verify(unitRepository).getTotalLessonsByUnitId(unitId);
        verify(unitProgressRepository).save(any(UnitProgress.class));
    }
}