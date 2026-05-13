package gravit.code.chapter.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class ChapterFacadeIntegrationTest {

    @Autowired
    private ChapterFacade chapterFacade;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("전체 챕터를 조회할 때")
    class GetAllChapter {

        @Test
        void 챕터_목록과_진행도를_함께_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, lesson1.getId(), userId));

            // when
            List<ChapterDetailResponse> result = chapterFacade.getAllChapter(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).chapterSummaryResponse().title()).isEqualTo("운영체제");
                softly.assertThat(result.get(0).chapterProgressRate()).isEqualTo(50.0);
            });
        }

        @Test
        void 학습_기록이_없으면_진행도가_0이다() {
            // given
            long userId = 1L;
            chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));

            // when
            List<ChapterDetailResponse> result = chapterFacade.getAllChapter(userId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).chapterProgressRate()).isEqualTo(0.0);
            });
        }

        @Test
        void 챕터가_없으면_빈_리스트를_반환한다() {
            // when
            List<ChapterDetailResponse> result = chapterFacade.getAllChapter(1L);

            // then
            assertThat(result).isEmpty();
        }
    }
}
