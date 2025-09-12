package gravit.code.domain.chapterProgress.service;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.ChapterProgressRepository;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.ChapterSummaryResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
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

    @Nested
    @DisplayName("ChapterProgressDetails를 조회할 때,")
    class FindChapterProgressDetails{

        @Test
        @DisplayName("비어있는 리스트가 조회되면 예외를 반환한다.")
        void withInvalidUserId(){
            //given
            Long userId = 1L;
            List<ChapterProgressDetailResponse> emptyList = List.of();

            when(chapterProgressRepository.findAllChapterProgressDetailByUserId(userId)).thenReturn(emptyList);

            //when&then
            assertThatThrownBy(() -> chapterProgressService.getChapterProgressDetails(userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
        }

        @Test
        @DisplayName("비어있지 않은 리스트가 조회되면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            Long userId = 1L;
            List<ChapterProgressDetailResponse> chapterProgressDetailResponse = List.of(
                    ChapterProgressDetailResponse.create(1L, "자료구조", "스택, 큐 등", 10L, 5L)
            );

            when(chapterProgressRepository.findAllChapterProgressDetailByUserId(userId)).thenReturn(chapterProgressDetailResponse);

            //when
            List<ChapterProgressDetailResponse> returnValue = chapterProgressService.getChapterProgressDetails(userId);

            //then
            assertThat(returnValue).isEqualTo(chapterProgressDetailResponse);
            assertThat(returnValue).hasSize(1);
        }
    }

    @Nested
    @DisplayName("ChapterSummary를 조회할 때,")
    class FindChapterSummary{

        @Test
        @DisplayName("조회에 실패하면 예외를 반환한다.")
        void withInvalidChapterIdAndUserId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            when(chapterProgressRepository.findChapterSummaryByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.empty());

            //when&then
            assertThatThrownBy(() -> chapterProgressService.getChapterSummary(chapterId, userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_SUMMARY_NOT_FOUND);
        }

        @Test
        @DisplayName("조회에 성공하면 정상적으로 반환한다.")
        void withValidChapterIdAndUserId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;
            ChapterSummaryResponse chapterSummaryResponse = ChapterSummaryResponse.create(1L, "이름", 10L, 5L);

            when(chapterProgressRepository.findChapterSummaryByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.of(chapterSummaryResponse));

            //when
            ChapterSummaryResponse returnValue = chapterProgressService.getChapterSummary(chapterId, userId);

            //then
            assertThat(returnValue).isEqualTo(chapterSummaryResponse);
        }
    }

    @Nested
    @DisplayName("ChapterProgress를 업데이트할 때,")
    class UpdateChapterProgress{

        @Test
        @DisplayName("전달받은 ChapterProgress의 완료된 유닛 수를 증가시킨다.")
        void updateCompletedUnits(){
            //given
            ChapterProgress chapterProgress = mock(ChapterProgress.class);

            //when
            chapterProgressService.updateChapterProgress(chapterProgress);

            //then
            verify(chapterProgress, times(1)).updateCompletedUnits();
        }
    }

    @Nested
    @DisplayName("ChapterProgress를 확보할 때,")
    class EnsureChapterProgress{

        @Test
        @DisplayName("Chapter 조회에 실패하면 예외를 반환한다.")
        void withInvalidChapterId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            when(chapterRepository.findById(chapterId)).thenReturn(Optional.empty());

            //when&then
            assertThatThrownBy(() -> chapterProgressService.ensureChapterProgress(chapterId, userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
        }

        @Test
        @DisplayName("기존 ChapterProgress가 존재하면 해당 객체를 저장 후 반환한다.")
        void withExistingChapterProgress(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;
            Chapter chapter = mock(Chapter.class);
            ChapterProgress existingProgress = mock(ChapterProgress.class);

            when(chapterRepository.findById(chapterId)).thenReturn(Optional.of(chapter));
            when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId))
                    .thenReturn(Optional.of(existingProgress));
            when(chapterProgressRepository.save(existingProgress)).thenReturn(existingProgress);

            //when
            ChapterProgress result = chapterProgressService.ensureChapterProgress(chapterId, userId);

            //then
            assertThat(result).isEqualTo(existingProgress);
            verify(chapterProgressRepository).save(existingProgress);
        }

        @Test
        @DisplayName("ChapterProgress가 존재하지 않으면 새로 생성한 후 저장하여 반환한다.")
        void withNewChapterProgress(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;
            Long totalUnits = 10L;
            Chapter chapter = mock(Chapter.class);
            ChapterProgress newProgress = mock(ChapterProgress.class);

            when(chapter.getTotalUnits()).thenReturn(totalUnits);
            when(chapterRepository.findById(chapterId)).thenReturn(Optional.of(chapter));
            when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.empty());
            when(chapterProgressRepository.save(any(ChapterProgress.class))).thenReturn(newProgress);

            //when
            ChapterProgress result = chapterProgressService.ensureChapterProgress(chapterId, userId);

            //then
            assertThat(result).isEqualTo(newProgress);
            verify(chapterProgressRepository).save(any(ChapterProgress.class));
        }
    }
}