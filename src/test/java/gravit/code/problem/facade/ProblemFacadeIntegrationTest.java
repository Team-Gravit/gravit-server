package gravit.code.problem.facade;

import gravit.code.answer.domain.Answer;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.option.domain.Option;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class ProblemFacadeIntegrationTest {

    @Autowired
    private ProblemFacade problemFacade;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private AnswerRepository answerRepository;

    @Autowired
    private OptionRepository optionRepository;

    @Autowired
    private ProblemSubmissionRepository problemSubmissionRepository;

    @Autowired
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Nested
    @DisplayName("레슨의 문제 목록을 조회할 때")
    class GetAllProblemInLesson {

        @Test
        void 주관식_문제의_유닛_정보와_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("스택/큐", "스택과 큐 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            answerRepository.save(Answer.create("LIFO", "스택은 Last In First Out 구조입니다.", problem.getId()));

            // when
            LessonResponse result = problemFacade.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("스택/큐");
                softly.assertThat(result.problems()).hasSize(1);
                softly.assertThat(result.totalProblems()).isEqualTo(1);
                softly.assertThat(result.problems().get(0).problemType()).isEqualTo(ProblemType.SUBJECTIVE);
                softly.assertThat(result.problems().get(0).answerResponse()).isNotNull();
            });
        }

        @Test
        void 객관식_문제의_유닛_정보와_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));
            optionRepository.save(Option.create("FIFO 구조이다.", "큐는 First In First Out 구조입니다.", true, problem.getId()));
            optionRepository.save(Option.create("LIFO 구조이다.", "이것은 스택의 특성입니다.", false, problem.getId()));

            // when
            LessonResponse result = problemFacade.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("연결리스트");
                softly.assertThat(result.problems()).hasSize(1);
                softly.assertThat(result.totalProblems()).isEqualTo(1);
                softly.assertThat(result.problems().get(0).problemType()).isEqualTo(ProblemType.OBJECTIVE);
                softly.assertThat(result.problems().get(0).options()).hasSize(2);
            });
        }

        @Test
        void 문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            LessonResponse result = problemFacade.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("연결리스트");
                softly.assertThat(result.problems()).isEmpty();
                softly.assertThat(result.totalProblems()).isEqualTo(0);
            });
        }

        @Test
        void 유닛이_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;
            long nonExistentLessonId = 999L;

            // when & then
            assertThatThrownBy(() -> problemFacade.getAllProblemInLesson(userId, nonExistentLessonId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("단일 문제 풀이 결과를 저장할 때")
    class SaveProblemSubmission {

        private static final long NOT_EXIST_PROBLEM_ID = 999_999L;

        private Problem 주관식_문제() {
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("스택/큐", "스택과 큐 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            return problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
        }

        private Problem 객관식_문제() {
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            return problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));
        }

        @Test
        void 정답이면_제출_이력만_저장한다() {
            // given
            long userId = 1L;
            Problem problem = 객관식_문제();
            ProblemSubmissionSaveRequest request = new ProblemSubmissionSaveRequest(problem.getId(), true, 2L, null);

            // when
            problemFacade.saveProblemSubmission(userId, request);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(1);
                softly.assertThat(saved.get(0).getSelectedOptionId()).isEqualTo(2L);
                softly.assertThat(saved.get(0).isCorrect()).isTrue();
                softly.assertThat(saved.get(0).getCreatedAt()).isNotNull();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 오답이면_오답_노트도_함께_저장한다() {
            // given
            long userId = 1L;
            Problem problem = 객관식_문제();
            ProblemSubmissionSaveRequest request = new ProblemSubmissionSaveRequest(problem.getId(), false, 1L, null);

            // when
            problemFacade.saveProblemSubmission(userId, request);

            // then
            assertSoftly(softly -> {
                softly.assertThat(problemSubmissionRepository.findAll()).hasSize(1);
                softly.assertThat(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problem.getId(), userId)).isPresent();
            });
        }

        @Test
        void 같은_문제를_다시_제출하면_이력이_누적된다() {
            // given
            long userId = 1L;
            Problem problem = 객관식_문제();
            ProblemSubmissionSaveRequest wrongTry = new ProblemSubmissionSaveRequest(problem.getId(), false, 1L, null);
            ProblemSubmissionSaveRequest correctTry = new ProblemSubmissionSaveRequest(problem.getId(), true, 2L, null);

            // when
            problemFacade.saveProblemSubmission(userId, wrongTry);
            problemFacade.saveProblemSubmission(userId, correctTry);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).extracting(ProblemSubmission::getSelectedOptionId)
                        .containsExactlyInAnyOrder(1L, 2L);
            });
        }

        @Test
        void 같은_문제를_반복해서_틀리면_오답_노트는_한_건으로_유지되고_틀린_횟수가_늘어난다() {
            // given
            long userId = 1L;
            Problem problem = 객관식_문제();
            ProblemSubmissionSaveRequest request = new ProblemSubmissionSaveRequest(problem.getId(), false, 1L, null);

            // when
            problemFacade.saveProblemSubmission(userId, request);
            problemFacade.saveProblemSubmission(userId, request);

            // then
            List<WrongAnsweredNote> notes = wrongAnsweredNoteRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(notes).hasSize(1);
                softly.assertThat(notes.get(0).getWrongCount()).isEqualTo(2);
            });
        }

        @Test
        void 객관식인데_선택한_보기가_없으면_아무것도_저장되지_않는다() {
            // given
            long userId = 1L;
            Problem problem = 객관식_문제();
            ProblemSubmissionSaveRequest request = new ProblemSubmissionSaveRequest(problem.getId(), false, null, null);

            // when
            assertThatThrownBy(() -> problemFacade.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);

            // then
            assertSoftly(softly -> {
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 주관식인데_제출_내용이_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            Problem problem = 주관식_문제();
            ProblemSubmissionSaveRequest request = new ProblemSubmissionSaveRequest(problem.getId(), true, null, null);

            // when & then
            assertThatThrownBy(() -> problemFacade.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 존재하지_않는_문제면_예외가_발생한다() {
            // given
            long userId = 1L;
            ProblemSubmissionSaveRequest request = new ProblemSubmissionSaveRequest(NOT_EXIST_PROBLEM_ID, true, 1L, null);

            // when & then
            assertThatThrownBy(() -> problemFacade.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_NOT_FOUND);
        }
    }
}
