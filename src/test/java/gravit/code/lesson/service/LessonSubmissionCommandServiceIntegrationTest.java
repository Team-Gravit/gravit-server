package gravit.code.lesson.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
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

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.tuple;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
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
            lessonSubmissionCommandService.saveLessonSubmission(userId, request);

            // then
            assertThat(lessonSubmissionRepository.existsByLessonIdAndUserId(lesson.getId(), userId)).isTrue();
        }

        @Test
        void 재풀이면_새_행을_저장한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            lessonSubmissionCommandService.saveLessonSubmission(userId, new LessonSubmissionSaveRequest(lesson.getId(), 120, 80));
            lessonSubmissionCommandService.saveLessonSubmission(userId, new LessonSubmissionSaveRequest(lesson.getId(), 90, 85));

            // then
            List<LessonSubmission> submissions = lessonSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(submissions).hasSize(2);
                softly.assertThat(submissions)
                        .extracting(LessonSubmission::getLearningTime, LessonSubmission::getAccuracy)
                        .containsExactlyInAnyOrder(tuple(120, 80), tuple(90, 85));
            });
        }
    }
}
