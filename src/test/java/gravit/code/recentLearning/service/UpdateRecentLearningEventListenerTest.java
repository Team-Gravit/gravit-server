package gravit.code.recentLearning.service;

import gravit.code.progress.dto.response.ChapterSummaryResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.recentLearning.dto.common.UpdateRecentLearningEvent;
import gravit.code.recentLearning.listener.RecentLearningEventListener;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UpdateRecentLearningEventListenerTest {

    @Mock
    private ChapterProgressService chapterProgressService;

    @Mock
    private RecentLearningService recentLearningService;

    @InjectMocks
    private RecentLearningEventListener recentLearningEventHandler;

    @Test
    @DisplayName("최근 학습 업데이트 이밴트가 발행되면, 최근 학습 업데이트 메소드가 호출된다.")
    void invokeUpdateRecentLearningWhenEventPublished() {
        //given
        Long userId = 1L;
        Long chapterId = 1L;

        UpdateRecentLearningEvent recentLearningEventDto = new UpdateRecentLearningEvent(userId, chapterId);
        ChapterSummaryResponse chapterSummaryResponse = mock(ChapterSummaryResponse.class);

        when(chapterProgressService.getChapterSummary(userId, chapterId)).thenReturn(chapterSummaryResponse);

        //when
        recentLearningEventHandler.updateRecentLearning(recentLearningEventDto);

        //then
        verify(chapterProgressService).getChapterSummary(recentLearningEventDto.chapterId(), recentLearningEventDto.userId());
        verify(recentLearningService).updateRecentLearning(recentLearningEventDto.userId(), chapterSummaryResponse);
    }
}