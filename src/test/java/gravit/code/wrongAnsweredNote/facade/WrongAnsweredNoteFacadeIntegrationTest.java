package gravit.code.wrongAnsweredNote.facade;

import gravit.code.answer.domain.Answer;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class WrongAnsweredNoteFacadeIntegrationTest {

    @Autowired
    private WrongAnsweredNoteFacade wrongAnsweredNoteFacade;

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
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Nested
    @DisplayName("유닛 내 오답 문제 목록을 조회할 때")
    class GetAllWrongAnsweredProblemInUnit {

        @Test
        void 유닛_정보와_오답_주관식_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("스택/큐", "스택과 큐 개념", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            answerRepository.save(Answer.create("LIFO", "스택은 Last In First Out 구조입니다.", problem.getId()));
            wrongAnsweredNoteRepository.save(WrongAnsweredNote.create(problem.getId(), userId));

            // when
            WrongAnsweredProblemsResponse result = wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.unitSummaryResponse().title()).isEqualTo("스택/큐");
                softly.assertThat(result.problems()).hasSize(1);
                softly.assertThat(result.totalProblems()).isEqualTo(1);
                softly.assertThat(result.problems().get(0).problemType()).isEqualTo(ProblemType.SUBJECTIVE);
            });
        }

        @Test
        void 오답_문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("스택/큐", "스택과 큐 개념", chapter.getId()));

            // when
            WrongAnsweredProblemsResponse result = wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.problems()).isEmpty();
                softly.assertThat(result.totalProblems()).isEqualTo(0);
            });
        }

        @Test
        void 유닛이_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;
            long nonExistentUnitId = 999L;

            // when & then
            assertThatThrownBy(() -> wrongAnsweredNoteFacade.getAllWrongAnsweredProblemInUnit(userId, nonExistentUnitId))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }
}
