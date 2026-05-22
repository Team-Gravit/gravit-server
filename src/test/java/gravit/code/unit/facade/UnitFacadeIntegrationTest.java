package gravit.code.unit.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.dto.response.UnitPageResponse;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class UnitFacadeIntegrationTest {

    @Autowired
    private UnitFacade unitFacade;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("챕터 내 유닛 목록을 조회할 때")
    class GetAllUnitInChapter {

        @Test
        void 챕터_정보와_유닛_목록_및_진행도를_함께_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            UnitPageResponse result = unitFacade.getAllUnitInChapter(userId, chapter.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterSummaryResponse().title()).isEqualTo("운영체제");
                softly.assertThat(result.unitDetailResponses()).hasSize(1);
                softly.assertThat(result.unitDetailResponses().get(0).unitSummaryResponse().title()).isEqualTo("프로세스");
                softly.assertThat(result.unitDetailResponses().get(0).progressRate()).isEqualTo(50.0);
            });
        }

        @Test
        void 학습_기록이_없으면_진행도가_0이다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            lessonRepository.save(Lesson.create("레슨1", unit.getId())); // 레슨은 존재하지만 제출 기록 없음

            // when
            UnitPageResponse result = unitFacade.getAllUnitInChapter(userId, chapter.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitDetailResponses()).hasSize(1);
                softly.assertThat(result.unitDetailResponses().get(0).progressRate()).isEqualTo(0.0);
            });
        }

        @Test
        void 유닛이_없으면_빈_유닛_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));

            // when
            UnitPageResponse result = unitFacade.getAllUnitInChapter(userId, chapter.getId());

            // then
            assertThat(result.unitDetailResponses()).isEmpty();
        }
    }
}
