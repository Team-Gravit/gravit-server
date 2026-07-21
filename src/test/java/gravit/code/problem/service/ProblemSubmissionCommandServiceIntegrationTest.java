package gravit.code.problem.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
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
    @DisplayName("레슨 풀이 제출 목록을 저장할 때")
    class SaveProblemSubmissions {

        @Test
        void 정답과_오답_제출을_모두_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, "LIFO"),
                    new ProblemSubmissionRequest(objectiveProblem.getId(), false, 3L, null)
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
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, "LIFO"),
                    new ProblemSubmissionRequest(objectiveProblem.getId(), false, 3L, null)
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
            List<ProblemSubmissionRequest> firstTry = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), false, null, "FIFO")
            );
            List<ProblemSubmissionRequest> secondTry = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, "LIFO")
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
        void 오답이면_오답_노트를_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), false, null, "FIFO")
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(wrongAnsweredNoteRepository.findByProblemIdAndUserId(subjectiveProblem.getId(), userId)).isPresent();
        }

        @Test
        void 같은_문제를_반복해서_틀려도_오답_노트는_한_건만_유지한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), false, null, "FIFO")
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertSoftly(softly -> {
                softly.assertThat(problemSubmissionRepository.findAll()).hasSize(3);
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).hasSize(1);
            });
        }

        @Test
        void 정답이면_오답_노트를_저장하지_않는다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, "LIFO")
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
        }

        @Test
        void 객관식인데_선택한_보기가_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(objectiveProblem.getId(), true, null, null)
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 주관식인데_제출_내용이_공백이면_예외가_발생한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, "  ")
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 주관식인데_제출_내용이_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, null)
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 제출_목록이_비어있으면_아무것도_저장하지_않는다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of();

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests);

            // then
            assertThat(problemSubmissionRepository.findAll()).isEmpty();
        }

        @Test
        void 다른_사용자의_제출과_섞이지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, "LIFO")
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

        @Test
        void 검증에_실패하면_앞선_제출도_저장되지_않는다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(subjectiveProblem.getId(), false, null, "FIFO"),
                    new ProblemSubmissionRequest(objectiveProblem.getId(), true, null, null)
            );

            // when
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests))
                    .isInstanceOf(RestApiException.class);

            // then
            assertSoftly(softly -> {
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 존재하지_않는_문제면_예외가_발생한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(NOT_EXIST_PROBLEM_ID, true, null, "LIFO")
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("단일 문제 제출을 저장할 때")
    class SaveProblemSubmission {

        @Test
        void 제출_내용과_함께_새_이력을_저장한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(objectiveProblem.getId(), true, 2L, null);

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(1);
                softly.assertThat(saved.get(0).getSelectedOptionId()).isEqualTo(2L);
                softly.assertThat(saved.get(0).isCorrect()).isTrue();
                softly.assertThat(saved.get(0).getCreatedAt()).isNotNull();
            });
        }

        @Test
        void 같은_문제를_다시_제출하면_이력이_누적된다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest wrongTry = new ProblemSubmissionRequest(objectiveProblem.getId(), false, 1L, null);
            ProblemSubmissionRequest correctTry = new ProblemSubmissionRequest(objectiveProblem.getId(), true, 2L, null);

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, wrongTry);
            problemSubmissionCommandService.saveProblemSubmission(userId, correctTry);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved).extracting(ProblemSubmission::getSelectedOptionId)
                        .containsExactlyInAnyOrder(1L, 2L);
            });
        }

        @Test
        void 오답이면_오답_노트를_저장한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(objectiveProblem.getId(), false, 1L, null);

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            assertThat(wrongAnsweredNoteRepository.findByProblemIdAndUserId(objectiveProblem.getId(), userId)).isPresent();
        }

        @Test
        void 객관식인데_선택한_보기가_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(objectiveProblem.getId(), true, null, null);

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 주관식인데_제출_내용이_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(subjectiveProblem.getId(), true, null, null);

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_TYPE_MISMATCH);
        }

        @Test
        void 검증에_실패하면_오답_노트도_저장되지_않는다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(objectiveProblem.getId(), false, null, null);

            // when
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class);

            // then
            assertSoftly(softly -> {
                softly.assertThat(problemSubmissionRepository.findAll()).isEmpty();
                softly.assertThat(wrongAnsweredNoteRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 존재하지_않는_문제면_예외가_발생한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(NOT_EXIST_PROBLEM_ID, true, 1L, null);

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PROBLEM_NOT_FOUND);
        }
    }
}
