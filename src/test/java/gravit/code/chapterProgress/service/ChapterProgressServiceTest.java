package gravit.code.chapterProgress.service;

import gravit.code.chapterProgress.domain.ChapterProgress;
import gravit.code.chapterProgress.repository.ChapterProgressRepository;
import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
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

    @InjectMocks
    private ChapterProgressService chapterProgressService;

    @Test
    @DisplayName("chapterId와 userId를 통해 ChapterProgress를 업데이트할 수 있다.")
    void updateChapterProgressByChapterIdAndUserId(){
        // given
        Long chapterId = 1L;
        Long userId = 1L;

        ChapterProgress mockChapterProgress = mock(ChapterProgress.class);

        when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.ofNullable(mockChapterProgress));

        // when
        chapterProgressService.updateChapterProgress(chapterId, userId);

        // then
        verify(chapterProgressRepository).findByChapterIdAndUserId(chapterId, userId);
        verify(mockChapterProgress).updateCompletedUnits();
    }

    @Test
    @DisplayName("chapterId와 userId를 통해 ChapterProgress 조회에 실패한 경우 예외를 반환한다.")
    void updateChapterProgressByNonExistChapterIdAndUserId(){
        // given
        Long chapterId = 11111L;
        Long userId = 11111L;

        when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> chapterProgressService.updateChapterProgress(chapterId, userId))
                .isInstanceOf(RestApiException.class)
                .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_PROGRESS_NOT_FOUND);
    }

}