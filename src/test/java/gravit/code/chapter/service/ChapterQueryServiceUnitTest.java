package gravit.code.chapter.service;

import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.repository.ChapterRepository;
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

import static gravit.code.global.exception.domain.CustomErrorCode.CHAPTER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChapterQueryServiceTest {

    @InjectMocks
    private ChapterQueryService chapterQueryService;

    @Mock
    private ChapterRepository chapterRepository;

    @Nested
    @DisplayName("전체 챕터를 조회할 때")
    class GetAllChapter {

        @Test
        void 성공한다() {
            // given
            List<ChapterSummaryResponse> expected = List.of(
                    new ChapterSummaryResponse(1L, "운영체제", "운영체제 기초 개념"),
                    new ChapterSummaryResponse(2L, "네트워크", "네트워크 기초 개념")
            );
            when(chapterRepository.findAllChapterSummary()).thenReturn(expected);

            // when
            List<ChapterSummaryResponse> result = chapterQueryService.getAllChapter();

            // then
            assertThat(result).hasSize(2);
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 챕터가_없으면_빈_리스트를_반환한다() {
            // given
            when(chapterRepository.findAllChapterSummary()).thenReturn(List.of());

            // when
            List<ChapterSummaryResponse> result = chapterQueryService.getAllChapter();

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("챕터를 단건 조회할 때")
    class GetChapterById {

        @Test
        void 성공한다() {
            // given
            long chapterId = 1L;
            ChapterSummaryResponse expected = new ChapterSummaryResponse(chapterId, "운영체제", "운영체제 기초 개념");
            when(chapterRepository.findChapterSummaryByChapterId(chapterId))
                    .thenReturn(Optional.of(expected));

            // when
            ChapterSummaryResponse result = chapterQueryService.getChapterSummary(chapterId);

            // then
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // given
            long chapterId = 999L;
            when(chapterRepository.findChapterSummaryByChapterId(chapterId))
                    .thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> chapterQueryService.getChapterSummary(chapterId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(CHAPTER_NOT_FOUND);
        }
    }
}
