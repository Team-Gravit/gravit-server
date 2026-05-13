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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_SUBMISSION_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class ProblemSubmissionCommandServiceIntegrationTest {

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

    private Problem problem1;
    private Problem problem2;

    @BeforeEach
    void setUp() {
        Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
        Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
        Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        problem1 = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
        problem2 = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));
    }

    @Nested
    @DisplayName("최초 레슨 풀이 제출 목록을 저장할 때")
    class SaveProblemSubmissionsFirstTry {

        @Test
        void 정답과_오답_제출을_모두_저장한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(problem1.getId(), true),
                    new ProblemSubmissionRequest(problem2.getId(), false)
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, true);

            // then
            List<ProblemSubmission> saved = problemSubmissionRepository.findByIdInIdsAndUserId(
                    List.of(problem1.getId(), problem2.getId()), userId
            );
            assertSoftly(softly -> {
                softly.assertThat(saved).hasSize(2);
                softly.assertThat(saved.stream().anyMatch(ProblemSubmission::isCorrect)).isTrue();
                softly.assertThat(saved.stream().anyMatch(s -> !s.isCorrect())).isTrue();
            });
        }
    }

    @Nested
    @DisplayName("재풀이 제출 목록을 저장할 때")
    class SaveProblemSubmissionsRetry {

        @Test
        void 기존_제출_이력을_업데이트한다() {
            // given
            long userId = 1L;
            problemSubmissionRepository.save(ProblemSubmission.create(false, problem1.getId(), userId));
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(problem1.getId(), true)
            );

            // when
            problemSubmissionCommandService.saveProblemSubmissions(userId, requests, false);

            // then
            ProblemSubmission updated = problemSubmissionRepository
                    .findByProblemIdAndUserId(problem1.getId(), userId).get();
            assertThat(updated.isCorrect()).isTrue();
        }

        @Test
        void 제출_이력이_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            List<ProblemSubmissionRequest> requests = List.of(
                    new ProblemSubmissionRequest(problem1.getId(), true)
            );

            // when & then
            assertThatThrownBy(() -> problemSubmissionCommandService.saveProblemSubmissions(userId, requests, false))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(PROBLEM_SUBMISSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("단일 문제 제출을 저장할 때")
    class SaveProblemSubmission {

        @Test
        void 기존_제출이_없으면_새로_생성한다() {
            // given
            long userId = 1L;
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(problem1.getId(), true);

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            assertThat(problemSubmissionRepository.findByProblemIdAndUserId(problem1.getId(), userId)).isPresent();
        }

        @Test
        void 기존_제출이_있으면_정답_여부를_업데이트한다() {
            // given
            long userId = 1L;
            problemSubmissionRepository.save(ProblemSubmission.create(false, problem1.getId(), userId));
            ProblemSubmissionRequest request = new ProblemSubmissionRequest(problem1.getId(), true);

            // when
            problemSubmissionCommandService.saveProblemSubmission(userId, request);

            // then
            ProblemSubmission updated = problemSubmissionRepository
                    .findByProblemIdAndUserId(problem1.getId(), userId).get();
            assertThat(updated.isCorrect()).isTrue();
        }
    }
}
