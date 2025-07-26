package gravit.code.domain.chapter.service;

import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChapterServiceTest {

    @Mock
    private ChapterRepository chapterRepository;

    @InjectMocks
    private ChapterService chapterService;

    @Test
    @DisplayName("userId를 통해 최근 학습 정보를 조회할 수 있다")
    void getRecentLearningInfoByUserId(){
        //given
        Long userId = 1L;

        RecentLearningInfo recentLearningInfo = mock(RecentLearningInfo.class);

        when(chapterRepository.findRecentLearningChapter(userId)).thenReturn(Optional.ofNullable(recentLearningInfo));

        //when
        chapterService.getRecentLearningChapter(userId);

        //then
        verify(chapterRepository, times(1)).findRecentLearningChapter(userId);
    }
}