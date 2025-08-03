package gravit.code.domain.recentLearning.service;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.recentLearning.domain.RecentLearning;
import gravit.code.domain.recentLearning.domain.RecentLearningRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RecentLearningServiceTest {

    @Mock
    private RecentLearningRepository recentLearningRepository;

    @InjectMocks
    private RecentLearningService recentLearningService;

    @Test
    @DisplayName("userId를 통해 RecentLearning을 초기화하고 저장할 수 있다.")
    void initAndSaveRecentLearningByUserId(){
        //given
        Long userId = 1L;
        RecentLearning recentLearning = mock(RecentLearning.class);

        // static 메소드를 모킹하는 방식
        try(MockedStatic<RecentLearning> mockedStatic = mockStatic(RecentLearning.class)){

            mockedStatic.when(() -> RecentLearning.init(userId))
                    .thenReturn(recentLearning);

            //when
            recentLearningService.initRecentLearning(userId);

            //then
            mockedStatic.verify(() -> RecentLearning.init(userId));
            verify(recentLearningRepository).save(recentLearning);
        }
    }

    @Test
    @DisplayName("userId와 ChapterInfo를 통해 RecentLearning을 수정할 수 있다.")
    void updateRecentLearningByUserIdAndChapterInfo(){
        //given
        Long userId = 1L;
        ChapterInfo chapterInfo = ChapterInfo.create(
                1L,
                "자료구조",
                3L,
                2L
        );

        RecentLearning recentLearning = mock(RecentLearning.class);

        when(recentLearningRepository.findByUserId(userId)).thenReturn(Optional.ofNullable(recentLearning));

        //when
        recentLearningService.updateRecentLearning(userId, chapterInfo);

        //then
        verify(recentLearning).update(chapterInfo);
        verify(recentLearningRepository).save(recentLearning);
    }
}