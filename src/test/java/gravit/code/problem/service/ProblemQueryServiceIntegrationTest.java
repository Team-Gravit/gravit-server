package gravit.code.problem.service;

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
class ProblemQueryServiceIntegrationTest {

    @Autowired
    private ProblemQueryService problemQueryService;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private BookmarkRepository bookmarkRepository;

    @Nested
    @DisplayName("레슨 내 문제 목록을 조회할 때")
    class GetAllProblemInLesson {

        @Test
        void 문제_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "다음 중 올바른 것을 고르시오.", "큐의 특성은?", lesson.getId()));

            // when
            List<ProblemDetailResponse> result = problemQueryService.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(2);
                softly.assertThat(result.get(0).problemType()).isEqualTo(ProblemType.SUBJECTIVE);
                softly.assertThat(result.get(1).problemType()).isEqualTo(ProblemType.OBJECTIVE);
                softly.assertThat(result.get(0).isBookmarked()).isFalse();
                softly.assertThat(result.get(1).isBookmarked()).isFalse();
            });
        }

        @Test
        void 북마크된_문제는_isBookmarked가_true이다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            bookmarkRepository.save(Bookmark.create(problem.getId(), userId));

            // when
            List<ProblemDetailResponse> result = problemQueryService.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertThat(result.get(0).isBookmarked()).isTrue();
        }

        @Test
        void 다른_사용자의_북마크는_반영되지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            bookmarkRepository.save(Bookmark.create(problem.getId(), otherUserId));

            // when
            List<ProblemDetailResponse> result = problemQueryService.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertThat(result.get(0).isBookmarked()).isFalse();
        }

        @Test
        void 문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));

            // when
            List<ProblemDetailResponse> result = problemQueryService.getAllProblemInLesson(userId, lesson.getId());

            // then
            assertThat(result).isEmpty();
        }
    }
}
