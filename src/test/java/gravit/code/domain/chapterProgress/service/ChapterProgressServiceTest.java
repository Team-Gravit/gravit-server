package gravit.code.domain.chapterProgress.service;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChapterProgressServiceTest {

    @Mock
    private ChapterProgressRepository chapterProgressRepository;

    @Mock
    private ChapterRepository chapterRepository;

    @InjectMocks
    private ChapterProgressService chapterProgressService;

    @Test
    @DisplayName("ChapterProgress를 업데이트할 때, Chapter 조회에 실패하면 예외를 반환한다.")
    void throwExceptionWhenUpdateChapterProgressIfFailedAtFindChapter(){
        //given
        Long userId = 1L;
        Long chapterId = 1L;

        when(chapterRepository.findById(chapterId)).thenReturn(Optional.empty());

        //when&then
        assertThatThrownBy(() -> chapterProgressService.updateChapterProgress(userId, chapterId))
                .isInstanceOf(RestApiException.class)
                .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
    }

    @Test
    @DisplayName("ChapterProgress를 업데이트 할때, ChapterProgress 조회에 실패하면 새로운 ChapterProgress를 생성해 업데이트한다.")
    void createNewChapterProgressWhenUpdateChapterProgressIfFailedAtFindChapterProgress(){
        //given
        Long userId = 1L;
        Long chapterId = 1L;
        Long totalUnits = 3L;
        Chapter chapter = Chapter.create("챕터", "설명", totalUnits);
        ChapterProgress chapterProgress = mock(ChapterProgress.class);

        when(chapterRepository.findById(chapterId)).thenReturn(Optional.of(chapter));
        when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.empty());
        when(chapterProgressRepository.save(any(ChapterProgress.class))).thenReturn(chapterProgress);

        //when
        chapterProgressService.updateChapterProgress(userId, chapterId);

        //then
        verify(chapterProgressRepository).save(any(ChapterProgress.class));
    }

    @Test
    @DisplayName("ChapterProgress를 업데이트할 때, ChapterProgress 조회에 성공하면 조회된 ChapterProgress를 업데이트한 후, 푼 유닛수와 총 유닛수가 같으면 true를 반환한다.")
    void updateChapterProgressAndReturnTrueWhenTotalUnitsEqualsCompletedUnits(){
        //given
        Long userId = 1L;
        Long chapterId = 1L;
        Long totalUnits = 2L;
        Chapter chapter = Chapter.create("챕터", "설명", totalUnits);
        ChapterProgress chapterProgress = mock(ChapterProgress.class);

        when(chapterRepository.findById(chapterId)).thenReturn(Optional.of(chapter));
        when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.of(chapterProgress));
        when(chapterProgressRepository.save(any(ChapterProgress.class))).thenReturn(chapterProgress);

        //when
        chapterProgressService.updateChapterProgress(userId, chapterId);

        //then
        verify(chapterProgress).updateCompletedUnits();
    }

}