package gravit.code.lesson.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.dto.response.LessonSummaryResponse;
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

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class LessonQueryServiceIntegrationTest {

    @Autowired
    private LessonQueryService lessonQueryService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("유닛별 레슨 목록을 조회할 때")
    class GetAllLessonInUnit {

        @Test
        void 성공한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, lesson1.getId(), userId));

            // when
            List<LessonSummaryResponse> result = lessonQueryService.getAllLessonInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).isSolved()).isTrue();
                softly.assertThat(result.get(1).isSolved()).isFalse();
            });
        }

        @Test
        void 레슨이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            // when
            List<LessonSummaryResponse> result = lessonQueryService.getAllLessonInUnit(userId, unit.getId());

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("레슨 ID로 학습 계층 ID를 조회할 때")
    class GetLearningIdsDtoByLessonId {

        @Test
        void 성공한다() {
            // given
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            LearningIdsDto result = lessonQueryService.getLearningIdsByLessonId(lesson.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.chapterId()).isEqualTo(chapter.getId());
                softly.assertThat(result.unitId()).isEqualTo(unit.getId());
                softly.assertThat(result.lessonId()).isEqualTo(lesson.getId());
            });
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> lessonQueryService.getLearningIdsByLessonId(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);
        }
    }
}
