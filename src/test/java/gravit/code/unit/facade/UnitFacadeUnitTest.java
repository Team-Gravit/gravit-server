package gravit.code.unit.facade;

import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.unit.dto.response.UnitPageResponse;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
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
class UnitFacadeUnitTest {

    @InjectMocks
    private UnitFacade unitFacade;

    @Mock
    private UnitQueryService unitQueryService;

    @Mock
    private ChapterQueryService chapterQueryService;

    @Mock
    private LearningProgressRateService learningProgressRateService;

    @Nested
    @DisplayName("챕터 내 유닛 목록을 조회할 때")
    class GetAllUnitInChapter {

        @Test
        void 챕터_정보와_유닛_목록_및_진행도를_함께_반환한다() {
            // given
            long userId = 1L;
            long chapterId = 1L;
            ChapterSummaryResponse chapterSummaryResponse = new ChapterSummaryResponse(chapterId, "운영체제", "운영체제 기초 개념");
            List<UnitSummaryResponse> unitSummaries = List.of(
                    new UnitSummaryResponse(1L, "프로세스", "프로세스 개념"),
                    new UnitSummaryResponse(2L, "스레드", "스레드 개념")
            );

            when(chapterQueryService.getChapterSummary(chapterId)).thenReturn(chapterSummaryResponse);
            when(unitQueryService.getAllUnitSummaryByChapterId(chapterId)).thenReturn(unitSummaries);
            when(learningProgressRateService.getUnitProgress(1L, userId)).thenReturn(80.0);
            when(learningProgressRateService.getUnitProgress(2L, userId)).thenReturn(0.0);

            // when
            UnitPageResponse result = unitFacade.getAllUnitInChapter(userId, chapterId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterSummaryResponse().title()).isEqualTo("운영체제");
                softly.assertThat(result.unitDetailResponses()).hasSize(2);
                softly.assertThat(result.unitDetailResponses().get(0).unitSummaryResponse().title()).isEqualTo("프로세스");
                softly.assertThat(result.unitDetailResponses().get(0).progressRate()).isEqualTo(80.0);
                softly.assertThat(result.unitDetailResponses().get(1).progressRate()).isEqualTo(0.0);
            });
        }

        @Test
        void 유닛이_없으면_빈_유닛_목록을_반환한다() {
            // given
            long userId = 1L;
            long chapterId = 1L;
            ChapterSummaryResponse chapterSummaryResponse = new ChapterSummaryResponse(chapterId, "운영체제", "운영체제 기초 개념");

            when(chapterQueryService.getChapterSummary(chapterId)).thenReturn(chapterSummaryResponse);
            when(unitQueryService.getAllUnitSummaryByChapterId(chapterId)).thenReturn(List.of());

            // when
            UnitPageResponse result = unitFacade.getAllUnitInChapter(userId, chapterId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterSummaryResponse().title()).isEqualTo("운영체제");
                softly.assertThat(result.unitDetailResponses()).isEmpty();
            });
        }
    }
}
