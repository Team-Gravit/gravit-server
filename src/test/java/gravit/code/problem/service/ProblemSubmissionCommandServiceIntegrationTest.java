package gravit.code.problem.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_TYPE_MISMATCH;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class ProblemSubmissionCommandServiceIntegrationTest {

    private static final long NOT_EXIST_PROBLEM_ID = 999_999L;

    @Autowired
    private ProblemSubmissionCommandService problemSubmissionCommandService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private ProblemSubmissionRepository problemSubmissionRepository;

    @Autowired
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    private Problem subjectiveProblem;
    private Problem objectiveProblem;

    @BeforeEach
    void setUp() {
        Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
        Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
        Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        subjectiveProblem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
        objectiveProblem = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));
    }

    @Nested
    @DisplayName("문제 풀이 제출 목록을 검증할 때")
    class ValidateProblemSubmissions {

        @Test
        void 문제_유형에_맞는_제출이면_통과한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO"),
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), false, 3L, null)
            );

            // when & then
            assertThatCode(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .doesNotThrowAnyException();
        }

        @Test
        void 제출_목록이_비어있으면_통과한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of();

            // when & then
            assertThatCode(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .doesNotThrowAnyException();
        }

        @Test
        void 검증만으로는_아무것도_저장하지_않는다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), false, null, "FIFO")
            );

            // when
            problemSubmissionCommandService.validateProblemSubmissions(requests);

            // then
            assertSoftly(softly -> {
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 객관식인데_선택한_보기가_없으면_예외가_발생한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), true, null, null)
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 주관식인데_제출_내용이_공백이면_예외가_발생한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "  ")
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 주관식인데_제출_내용이_없으면_예외가_발생한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, null)
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 존재하지_않는_문제면_예외가_발생한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(NOT_EXIST_PROBLEM_ID, true, null, "LIFO")
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_NOT_FOUND);
        }

        @Test
        void 목록_뒤쪽_제출이_잘못돼도_예외가_발생한다() {
            // given
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), false, null, "FIFO"),
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), true, null, null)
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.validateProblemSubmissions(requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }
    }

    @Nested
    @DisplayName("문제 풀이 제출 목록을 저장할 때")
    class SaveProblemSubmissions {

        @Test
        void 정답과_오답_제출을_모두_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO"),
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), false, 3L, null)
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved.stream().anyMatch(ProblemSubmission::isCorrect)).isTrue();
                softly.assertThat(saved.stream().anyMatch(s -> !s.isCorrect())).isTrue();
            });
        }

        @Test
        void 제출한_답안_내용과_제출_시각을_함께_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO"),
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), false, 3L, null)
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            ProblemSubmission subjective = saved.stream()
                    .filter(s -> s.getProblemId() == subjectiveProblem.getId())
                    .findFirst()
                    .orElseThrow();
            ProblemSubmission objective = saved.stream()
                    .filter(s -> s.getProblemId() == objectiveProblem.getId())
                    .findFirst()
                    .orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(subjective.getSubmittedContent()).isEqualTo("LIFO");
                softly.assertThat(subjective.getSelectedOptionId()).isNull();
                softly.assertThat(objective.getSelectedOptionId()).isEqualTo(3L);
                softly.assertThat(objective.getSubmittedContent()).isNull();
                softly.assertThat(subjective.getCreatedAt()).isNotNull();
                softly.assertThat(objective.getCreatedAt()).isNotNull();
            });
        }

        @Test
        void 같은_문제를_다시_제출하면_덮어쓰지_않고_이력을_쌓는다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> firstTry = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), false, null, "FIFO")
            );
            List<ProblemSubmissionSaveRequest> secondTry = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO")
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, firstTry);
            problemSubmissionCommandService.saveProblemSubmissions(userId, secondTry);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).extracting(ProblemSubmission::getSubmittedContent)
                        .containsExactlyInAnyOrder("FIFO", "LIFO");
                softly.assertThat(saved).extracting(ProblemSubmission::isCorrect)
                        .containsExactlyInAnyOrder(false, true);
            });
        }

        @Test
        void 오답_문제_아이디만_요청_순서대로_반환한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), false, 3L, null),
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO")
            );

            // when
            List<Long> result = problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(result).containsExactly(objectiveProblem.getId());
        }

        @Test
        void 모두_오답이면_모든_문제_아이디를_반환한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), false, null, "FIFO"),
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), false, 3L, null)
            );

            // when
            List<Long> result = problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(result).containsExactly(subjectiveProblem.getId(), objectiveProblem.getId());
        }

        @Test
        void 모두_정답이면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO"),
                    new ProblemSubmissionSaveRequest(objectiveProblem.getId(), true, 3L, null)
            );

            // when
            List<Long> result = problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 오답이어도_오답_노트는_저장하지_않는다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), false, null, "FIFO")
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
        }

        @Test
        void 제출_목록이_비어있으면_아무것도_저장하지_않고_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionSaveRequest> requests = List.of();

            // when
            List<Long> result = problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).isEmpty();
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 다른_사용자의_제출과_섞이지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            List<ProblemSubmissionSaveRequest> requests = List.of(
                    new ProblemSubmissionSaveRequest(subjectiveProblem.getId(), true, null, "LIFO")
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);
            problemSubmissionCommandService.saveProblemSubmissions(otherUserId, requests);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).extracting(ProblemSubmission::getUserId)
                        .containsExactlyInAnyOrder(userId, otherUserId);
            });
        }
    }
}
