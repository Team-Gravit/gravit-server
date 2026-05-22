package gravit.code.chapter.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.CHAPTER_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class ChapterQueryServiceIntegrationTest {

    @Autowired
    private ChapterQueryService chapterQueryService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Nested
    @DisplayName("전체 챕터를 조회할 때")
    class GetAllChapter {

        @Test
        void 성공한다() {
            // given
            chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            chapterRepository.save(Chapter.create("네트워크", "네트워크 기초 개념"));

            // when
            List<ChapterSummaryResponse> result = chapterQueryService.getAllChapter();

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).title()).isEqualTo("운영체제");
                softly.assertThat(result.get(1).title()).isEqualTo("네트워크");
            });
        }

        @Test
        void 챕터가_없으면_빈_리스트를_반환한다() {
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
            Chapter saved = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));

            // when
            ChapterSummaryResponse result = chapterQueryService.getChapterSummary(saved.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterId()).isEqualTo(saved.getId());
                softly.assertThat(result.title()).isEqualTo("운영체제");
                softly.assertThat(result.description()).isEqualTo("운영체제 기초 개념");
            });
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> chapterQueryService.getChapterSummary(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(CHAPTER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("챕터 엔티티를 조회할 때")
    class GetChapter {

        @Test
        void 성공한다() {
            // given
            Chapter saved = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));

            // when
            Chapter result = chapterQueryService.getChapter(saved.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.getId()).isEqualTo(saved.getId());
                softly.assertThat(result.getTitle()).isEqualTo("운영체제");
                softly.assertThat(result.getDescription()).isEqualTo("운영체제 기초 개념");
            });
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> chapterQueryService.getChapter(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(CHAPTER_NOT_FOUND);
        }
    }
}
