package gravit.code.domain.chapterProgress.service;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse;
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
            List<ChapterProgressDetailResponse> notEmptyList = List.of(
                    ChapterProgressDetailResponse.create(1L,"이름1", "설명1", 10L, 5L),
                    ChapterProgressDetailResponse.create(1L,"이름2", "설명1", 10L, 5L),
                    ChapterProgressDetailResponse.create(1L,"이름3", "설명1", 10L, 5L),
                    ChapterProgressDetailResponse.create(1L,"이름4", "설명1", 10L, 5L),
                    ChapterProgressDetailResponse.create(1L,"이름5", "설명1", 10L, 5L)
            );

            when(chapterProgressRepository.findAllChapterProgressDetailByUserId(userId)).thenReturn(notEmptyList);

            //when
            List<ChapterProgressDetailResponse> returnValue = chapterProgressService.getChapterProgressDetails(userId);

            //then
            assertThat(returnValue).hasSize(notEmptyList.size());

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
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_INFO_NOT_FOUND);
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
        @DisplayName("Chapter 조회에 실패하면 예외를 반환한다.")
        void withInvalidChapterId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            when(chapterRepository.findById(chapterId)).thenReturn(Optional.empty());

            //when&then
            assertThatThrownBy(() -> chapterProgressService.updateChapterProgress(chapterId, userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
        }

        @Test
        @DisplayName("Chapter 조회에 성공하고 ChapterProgress 조회에 실패하면 ChapterProgress를 생성한 후 업데이트한다.")
        void withValidChapterIdAndFailedAtFindChapterProgressThenCreateChapterProgress(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            Chapter chapter = mock(Chapter.class);
            ChapterProgress chapterProgress = mock(ChapterProgress.class);

            when(chapterRepository.findById(chapterId)).thenReturn(Optional.of(chapter));
            when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.of(chapterProgress));

            //when
            chapterProgressService.updateChapterProgress(chapterId, userId);

            //then
            verify(chapterProgressRepository).save(chapterProgress);
        }

        @Test
        @DisplayName("Chapter 조회에 성공하고 ChapterProgress 조회도 성공하면 ChapterProgress를 생성한 후 업데이트한다.")
        void withValidChapterIdAndSucceedAtFindChapterProgressThenCreateChapterProgress(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            Chapter chapter = mock(Chapter.class);

            when(chapterRepository.findById(chapterId)).thenReturn(Optional.of(chapter));
            when(chapterProgressRepository.findByChapterIdAndUserId(chapterId, userId)).thenReturn(Optional.empty());

            //when
            chapterProgressService.updateChapterProgress(chapterId, userId);

            //then
            verify(chapterProgressRepository).save(any(ChapterProgress.class));
        }
    }
}