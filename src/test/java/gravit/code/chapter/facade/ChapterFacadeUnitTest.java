package gravit.code.chapter.facade;

import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.learning.service.LearningProgressRateService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChapterFacadeUnitTest {

    @InjectMocks
    private ChapterFacade chapterFacade;

    @Mock
    private ChapterQueryService chapterQueryService;

    @Mock
    private LearningProgressRateService learningProgressRateService;

    @Nested
    @DisplayName("전체 챕터를 조회할 때")
    class GetAllChapter {

        @Test
        void 챕터_목록과_진행도를_함께_반환한다() {
            // given
            long userId = 1L;
            List<ChapterSummaryResponse> chapters = List.of(
                    new ChapterSummaryResponse(1L, "운영체제", "운영체제 기초 개념"),
                    new ChapterSummaryResponse(2L, "네트워크", "네트워크 기초 개념")
            );
            when(chapterQueryService.getAllChapter()).thenReturn(chapters);
            when(learningProgressRateService.getChapterProgress(1L, userId)).thenReturn(50.0);
            when(learningProgressRateService.getChapterProgress(2L, userId)).thenReturn(30.0);

            // when
            List<ChapterDetailResponse> result = chapterFacade.getAllChapter(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).chapterSummaryResponse().title()).isEqualTo("운영체제");
                softly.assertThat(result.get(0).chapterProgressRate()).isEqualTo(50.0);
                softly.assertThat(result.get(1).chapterSummaryResponse().title()).isEqualTo("네트워크");
                softly.assertThat(result.get(1).chapterProgressRate()).isEqualTo(30.0);
            });
        }

        @Test
        void 챕터가_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            when(chapterQueryService.getAllChapter()).thenReturn(List.of());

            // when
            List<ChapterDetailResponse> result = chapterFacade.getAllChapter(userId);

            // then
            assertThat(result).isEmpty();
        }
    }
}
