package gravit.code.bookmark.service;

import gravit.code.bookmark.dto.request.BookmarkDeleteRequest;
import gravit.code.bookmark.dto.request.BookmarkSaveRequest;
import gravit.code.bookmark.fixture.BookmarkFixture;
import gravit.code.bookmark.repository.BookmarkRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.BOOKMARK_DUPLICATED;
import static gravit.code.global.exception.domain.CustomErrorCode.BOOKMARK_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookmarkServiceUnitTest {

    @InjectMocks
    private BookmarkService bookmarkService;

    @Mock
    private BookmarkRepository bookmarkRepository;

    @Nested
    @DisplayName("북마크를 추가할 때")
    class AddBookmark {

        @Test
        void 북마크가_없으면_추가에_성공한다() {
            // given
            long userId = 1L;
            BookmarkSaveRequest request = new BookmarkSaveRequest(1L);

            when(bookmarkRepository.existsByProblemIdAndUserId(1L, userId)).thenReturn(false);
            when(bookmarkRepository.save(any())).thenReturn(BookmarkFixture.기본_북마크(1L, userId));

            // when
            bookmarkService.addBookmark(userId, request);

            // then
            verify(bookmarkRepository).save(any());
        }

        @Test
        void 이미_북마크된_문제면_예외가_발생한다() {
            // given
            long userId = 1L;
            BookmarkSaveRequest request = new BookmarkSaveRequest(1L);

            when(bookmarkRepository.existsByProblemIdAndUserId(1L, userId)).thenReturn(true);

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
        void 북마크가_있으면_삭제에_성공한다() {
            // given
            long userId = 1L;
            BookmarkDeleteRequest request = new BookmarkDeleteRequest(1L);

            when(bookmarkRepository.existsByProblemIdAndUserId(1L, userId)).thenReturn(true);

            // when
            bookmarkService.deleteBookmark(userId, request);

            // then
            verify(bookmarkRepository).deleteByProblemIdAndUserId(1L, userId);
        }

        @Test
        void 북마크가_없으면_예외가_발생한다() {
            // given
            long userId = 1L;
            BookmarkDeleteRequest request = new BookmarkDeleteRequest(1L);

            when(bookmarkRepository.existsByProblemIdAndUserId(1L, userId)).thenReturn(false);

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
            long unitId = 1L;

            when(bookmarkRepository.countByUnitIdAndUserId(unitId, userId)).thenReturn(3);

            // when
            boolean result = bookmarkService.checkBookmarkedProblemExists(userId, unitId);

            // then
            assertThat(result).isTrue();
        }

        @Test
        void 북마크가_없으면_false를_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;

            when(bookmarkRepository.countByUnitIdAndUserId(unitId, userId)).thenReturn(0);

            // when
            boolean result = bookmarkService.checkBookmarkedProblemExists(userId, unitId);

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
            long unitId = 1L;
            List<ProblemDetailResponse> expected = List.of(
                    new ProblemDetailResponse(1L, ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", true)
            );

            when(bookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId(unitId, userId)).thenReturn(expected);

            // when
            List<ProblemDetailResponse> result = bookmarkService.getAllBookmarkedProblemInUnit(userId, unitId);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(result.get(0).isBookmarked()).isTrue();
            });
        }

        @Test
        void 북마크된_문제가_없으면_빈_목록을_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;

            when(bookmarkRepository.findBookmarkedProblemDetailByUnitIdAndUserId(unitId, userId)).thenReturn(List.of());

            // when
            List<ProblemDetailResponse> result = bookmarkService.getAllBookmarkedProblemInUnit(userId, unitId);

            // then
            assertThat(result).isEmpty();
        }
    }
}
