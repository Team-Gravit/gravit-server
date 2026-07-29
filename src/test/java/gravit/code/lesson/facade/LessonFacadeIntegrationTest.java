package gravit.code.lesson.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_TYPE_MISMATCH;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class LessonFacadeIntegrationTest {

    @Autowired
    private LessonFacade lessonFacade;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private ProblemSubmissionRepository problemSubmissionRepository;

    @Autowired
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Nested
    @DisplayName("유닛별 레슨 목록을 조회할 때")
    class GetAllLessonInUnit {

        @Test
        void 유닛_정보와_레슨_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));
            Lesson lesson1 = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            lessonRepository.save(Lesson.create("레슨2", unit.getId()));
            lessonSubmissionRepository.save(LessonSubmission.create(120, 100, lesson1.getId(), userId));

            // when
            LessonDetailResponse result = lessonFacade.getAllLessonInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("프로세스");
                softly.assertThat(result.lessonSummaries()).hasSize(2);
                softly.assertThat(result.lessonSummaries().get(0).isSolved()).isTrue();
                softly.assertThat(result.lessonSummaries().get(1).isSolved()).isFalse();
            });
        }

        @Test
        void 레슨이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            // when
            LessonDetailResponse result = lessonFacade.getAllLessonInUnit(userId, unit.getId());

            // then
            assertThat(result.lessonSummaries()).isEmpty();
        }
    }

    @Nested
    @DisplayName("레슨 풀이 결과를 저장할 때")
    class SaveLessonSubmission {

        private static final long NOT_EXIST_LESSON_ID = 999_999L;
        private static final long NOT_EXIST_PROBLEM_ID = 999_999L;

        private Lesson 레슨() {
            Chapter chapter = chapterRepository.save(Chapter.create("운영체제", "운영체제 기초 개념"));
            Unit unit = unitRepository.save(Unit.create("프로세스", "프로세스 개념", chapter.getId()));

            return lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        }

        @Test
        void 레슨이_존재하지_않으면_아무것도_저장하지_않는다() {
            // given
            long userId = 1L;
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(NOT_EXIST_LESSON_ID, 120, 80),
                    List.of(new ProblemSubmissionSaveRequest(1L, true, null, "LIFO"))
            );

            // when
            assertThatThrownBy(() -> lessonFacade.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lessonSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 문제_유형에_맞지_않는_제출이_있으면_레슨_제출도_저장되지_않는다() {
            // given
            long userId = 1L;
            Lesson lesson = 레슨();
            Problem problem = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(lesson.getId(), 120, 80),
                    List.of(new ProblemSubmissionSaveRequest(problem.getId(), false, null, null))
            );

            // when
            assertThatThrownBy(() -> lessonFacade.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lessonSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 존재하지_않는_문제가_있으면_레슨_제출도_저장되지_않는다() {
            // given
            long userId = 1L;
            Lesson lesson = 레슨();
            LearningSubmissionSaveRequest request = new LearningSubmissionSaveRequest(
                    new LessonSubmissionSaveRequest(lesson.getId(), 120, 80),
                    List.of(new ProblemSubmissionSaveRequest(NOT_EXIST_PROBLEM_ID, true, null, "LIFO"))
            );

            // when
            assertThatThrownBy(() -> lessonFacade.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_NOT_FOUND);

            // then
            assertSoftly(softly -> {
                softly.assertThat(lessonSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }
    }
}
