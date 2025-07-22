package gravit.code.unitProgress.service;

import gravit.code.unitProgress.domain.UnitProgress;
import gravit.code.unitProgress.repository.UnitProgressRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UnitProgressServiceTest {

    @Mock
    private UnitProgressRepository unitProgressRepository;

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
}