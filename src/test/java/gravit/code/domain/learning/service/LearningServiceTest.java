package gravit.code.domain.learning.service;

import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.lessonProgress.service.LessonProgressService;
import gravit.code.domain.unitProgress.service.UnitProgressService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LearningServiceTest {

    @Mock
    private ChapterProgressService chapterProgressService;

    @Mock
    private UnitProgressService unitProgressService;

    @Mock
    private LessonProgressService lessonProgressService;

    @InjectMocks
    private LearningService learningService;

    @Test
    @DisplayName("LessonProgress가 이미 존재하는 경우 Unit, Chapter Progress는 생성되지 않는다")
    void shouldNotCreateWhenLessonProgressAlreadyExists() {
        // given
        Long userId = 1L;
        Long chapterId = 1L;
        Long unitId = 1L;
        Long lessonId = 1L;

        when(lessonProgressService.createLessonProgress(userId, lessonId)).thenReturn(false);

        // when
        learningService.initLearningProgress(userId, chapterId, unitId, lessonId);

        // then
        verify(lessonProgressService).createLessonProgress(userId, lessonId);
        verify(unitProgressService, never()).createUnitProgress(userId, unitId);
        verify(chapterProgressService, never()).createChapterProgress(userId, chapterId);
    }

    @Test
    @DisplayName("LessonProgress는 새로 생성, UnitProgress가 이미 존재하는 경우 ChapterProgress는 생성되지 않는다")
    void shouldNotCreateChapterWhenUnitProgressAlreadyExists() {
        // given
        Long userId = 1L;
        Long chapterId = 1L;
        Long unitId = 1L;
        Long lessonId = 1L;

        when(lessonProgressService.createLessonProgress(userId, lessonId)).thenReturn(true);
        when(unitProgressService.createUnitProgress(userId, unitId)).thenReturn(false);

        // when
        learningService.initLearningProgress(userId, chapterId, unitId, lessonId);

        // then
        verify(lessonProgressService).createLessonProgress(userId, lessonId);
        verify(unitProgressService).createUnitProgress(userId, unitId);
        verify(chapterProgressService, never()).createChapterProgress(userId, chapterId);
    }

    @Test
    @DisplayName("LessonProgress와 UnitProgress 모두 새로 생성되는 경우 ChapterProgress도 생성 시도한다")
    void shouldCreateAllWhenBothLessonAndUnitProgressAreNew() {
        // given
        Long userId = 1L;
        Long chapterId = 1L;
        Long unitId = 1L;
        Long lessonId = 1L;

        when(lessonProgressService.createLessonProgress(userId, lessonId)).thenReturn(true);
        when(unitProgressService.createUnitProgress(userId, unitId)).thenReturn(true);

        // when
        learningService.initLearningProgress(userId, chapterId, unitId, lessonId);

        // then
        verify(lessonProgressService).createLessonProgress(userId, lessonId);
        verify(unitProgressService).createUnitProgress(userId, unitId);
        verify(chapterProgressService).createChapterProgress(userId, chapterId);
    }

}