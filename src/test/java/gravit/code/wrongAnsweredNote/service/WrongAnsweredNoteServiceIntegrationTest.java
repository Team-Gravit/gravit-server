package gravit.code.wrongAnsweredNote.service;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.bookmark.repository.BookmarkRepository;
import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.repository.WrongAnsweredNoteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class WrongAnsweredNoteServiceIntegrationTest {

    @Autowired
    private WrongAnsweredNoteService wrongAnsweredNoteService;

    @Autowired
    private WrongAnsweredNoteRepository wrongAnsweredNoteRepository;

    @Autowired
    private BookmarkRepository bookmarkRepository;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    private Unit unit;
    private Problem problem;

    @BeforeEach
    void setUp() {
        Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
        unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
        Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
        problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
    }

    @Nested
    @DisplayName("오답 노트를 저장할 때")
    class SaveWrongAnsweredNote {

        @Test
        void 처음_오답이면_새로_생성한다() {
            // given
            long userId = 1L;

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problem.getId());

            // then
            assertThat(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problem.getId(), userId)).isPresent();
        }

        @Test
        void 이미_오답_노트가_있으면_중복_생성하지_않는다() {
            // given
            long userId = 1L;
            wrongAnsweredNoteRepository.save(WrongAnsweredNote.create(problem.getId(), userId));

            // when
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problem.getId());

            // then
            long count = wrongAnsweredNoteRepository.findAll().stream()
                    .filter(w -> w.getProblemId() == problem.getId() && w.getUserId() == userId)
                    .count();
            assertThat(count).isEqualTo(1);
        }
    }

    @Nested
    @DisplayName("유닛 내 오답 문제 목록을 조회할 때")
    class GetAllWrongAnsweredProblemInUnit {

        @Test
        void 오답_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            wrongAnsweredNoteRepository.save(WrongAnsweredNote.create(problem.getId(), userId));

            // when
            List<ProblemDetailResponse> result = wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).id()).isEqualTo(problem.getId());
                softly.assertThat(result.get(0).isBookmarked()).isFalse();
            });
        }

        @Test
        void 북마크된_오답_문제는_isBookmarked가_true이다() {
            // given
            long userId = 1L;
            wrongAnsweredNoteRepository.save(WrongAnsweredNote.create(problem.getId(), userId));
            bookmarkRepository.save(Bookmark.create(problem.getId(), userId));

            // when
            List<ProblemDetailResponse> result = wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unit.getId());

            // then
            assertThat(result.get(0).isBookmarked()).isTrue();
        }

        @Test
        void 오답_문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;

            // when
            List<ProblemDetailResponse> result = wrongAnsweredNoteService.getAllWrongAnsweredProblemInUnit(userId, unit.getId());

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("오답 문제를 삭제할 때")
    class DeleteWrongAnsweredProblem {

        @Test
        void 오답_노트에서_삭제에_성공한다() {
            // given
            long userId = 1L;
            wrongAnsweredNoteRepository.save(WrongAnsweredNote.create(problem.getId(), userId));

            // when
            wrongAnsweredNoteService.deleteWrongAnsweredProblem(userId, problem.getId());

            // then
            assertThat(wrongAnsweredNoteRepository.findByProblemIdAndUserId(problem.getId(), userId)).isEmpty();
        }
    }

    @Nested
    @DisplayName("유닛 내 오답 존재 여부를 확인할 때")
    class CheckWrongAnsweredProblemExists {

        @Test
        void 오답이_있으면_true를_반환한다() {
            // given
            long userId = 1L;
            wrongAnsweredNoteRepository.save(WrongAnsweredNote.create(problem.getId(), userId));

            // when
            boolean result = wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unit.getId());

            // then
            assertThat(result).isTrue();
        }

        @Test
        void 오답이_없으면_false를_반환한다() {
            // given
            long userId = 1L;

            // when
            boolean result = wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unit.getId());

            // then
            assertThat(result).isFalse();
        }
    }
}
