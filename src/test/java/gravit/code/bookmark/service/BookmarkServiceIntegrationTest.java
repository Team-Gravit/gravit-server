package gravit.code.bookmark.service;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.bookmark.repository.BookmarkRepository;
import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.repository.ProblemRepository;
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

import static gravit.code.global.exception.domain.CustomErrorCode.BOOKMARK_DUPLICATED;
import static gravit.code.global.exception.domain.CustomErrorCode.BOOKMARK_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class BookmarkServiceIntegrationTest {

    @Autowired
    private BookmarkService bookmarkService;

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
    @DisplayName("북마크를 추가할 때")
    class AddBookmark {

        @Test
        void 북마크_추가에_성공한다() {
            // given
            long userId = 1L;
            BookmarkSaveRequest request = new BookmarkSaveRequest(problem.getId());

            // when
            bookmarkService.addBookmark(userId, request);

            // then
            assertThat(bookmarkRepository.existsByProblemIdAndUserId(problem.getId(), userId)).isTrue();
        }

        @Test
        void 이미_북마크된_문제면_예외가_발생한다() {
            // given
            long userId = 1L;
            bookmarkRepository.save(Bookmark.create(problem.getId(), userId));
            BookmarkSaveRequest request = new BookmarkSaveRequest(problem.getId());

            // when & then
            assertThatThrownBy(() -> bookmarkService.addBookmark(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(BOOKMARK_DUPLICATED);
        }
    }

    @Nested
    @DisplayName("북마크를 삭제할 때")
    class DeleteBookmark {

        @Test
        void 북마크_삭제에_성공한다() {
            // given
            long userId = 1L;
            bookmarkRepository.save(Bookmark.create(problem.getId(), userId));
            BookmarkDeleteRequest request = new BookmarkDeleteRequest(problem.getId());

            // when
            bookmarkService.deleteBookmark(userId, request);

            // then
            assertThat(bookmarkRepository.existsByProblemIdAndUserId(problem.getId(), userId)).isFalse();
        }

        @Test
        void 북마크가_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            BookmarkDeleteRequest request = new BookmarkDeleteRequest(problem.getId());

            // when & then
            assertThatThrownBy(() -> bookmarkService.deleteBookmark(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(BOOKMARK_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("유닛 내 북마크 존재 여부를 확인할 때")
    class CheckBookmarkedProblemExists {

        @Test
        void 북마크가_있으면_true를_반환한다() {
            // given
            long userId = 1L;
            bookmarkRepository.save(Bookmark.create(problem.getId(), userId));

            // when
            boolean result = bookmarkService.checkBookmarkedProblemExists(userId, unit.getId());

            // then
            assertThat(result).isTrue();
        }

        @Test
        void 북마크가_없으면_false를_반환한다() {
            // given
            long userId = 1L;

            // when
            boolean result = bookmarkService.checkBookmarkedProblemExists(userId, unit.getId());

            // then
            assertThat(result).isFalse();
        }
    }

    @Nested
    @DisplayName("유닛 내 북마크된 문제 목록을 조회할 때")
    class GetAllBookmarkedProblemInUnit {

        @Test
        void 북마크된_문제_목록을_반환한다() {
            // given
            long userId = 1L;
            bookmarkRepository.save(Bookmark.create(problem.getId(), userId));

            // when
            List<ProblemDetailResponse> result = bookmarkService.getAllBookmarkedProblemInUnit(userId, unit.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).id()).isEqualTo(problem.getId());
                softly.assertThat(result.get(0).isBookmarked()).isTrue();
            });
        }

        @Test
        void 다른_사용자의_북마크는_조회되지_않는다() {
            // given
            long userId = 1L;
            long otherUserId = 2L;
            bookmarkRepository.save(Bookmark.create(problem.getId(), otherUserId));

            // when
            List<ProblemDetailResponse> result = bookmarkService.getAllBookmarkedProblemInUnit(userId, unit.getId());

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 북마크된_문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;

            // when
            List<ProblemDetailResponse> result = bookmarkService.getAllBookmarkedProblemInUnit(userId, unit.getId());

            // then
            assertThat(result).isEmpty();
        }
    }
}
