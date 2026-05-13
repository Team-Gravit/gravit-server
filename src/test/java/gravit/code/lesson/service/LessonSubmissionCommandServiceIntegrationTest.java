package gravit.code.lesson.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
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
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class LessonSubmissionCommandServiceIntegrationTest {

    @Autowired
    private LessonSubmissionCommandService lessonSubmissionCommandService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("레슨 풀이 결과를 저장할 때")
    class SaveLessonSubmission {

        @Test
        void 첫_풀이면_새로_생성한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(lesson.getId(), 120, 80);

            // when
            lessonSubmissionCommandService.saveLessonSubmission(userId, request, true);

            // then
            assertThat(lessonSubmissionRepository.existsByLessonIdAndUserId(lesson.getId(), userId)).isTrue();
        }

        @Test
        void 재풀이면_기존_기록을_업데이트한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, lesson.getId(), userId));
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(lesson.getId(), 90, 85);

            // when
            lessonSubmissionCommandService.saveLessonSubmission(userId, request, false);

            // then
            LessonSubmission updated = lessonSubmissionRepository.findByLessonIdAndUserId(lesson.getId(), userId).get();
            assertSoftly(softly -> {
                softly.assertThat(updated.getLearningTime()).isEqualTo(90);
                softly.assertThat(updated.getTryCount()).isEqualTo(2);
            });
        }

        @Test
        void 레슨이_존재하지_않으면_예외를_던진다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(999L, 120, 80);

            // when & then
            assertThatThrownBy(() -> lessonSubmissionCommandService.saveLessonSubmission(userId, request, true))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);
        }
    }
}
