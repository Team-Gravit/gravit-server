package gravit.code.bookmark.infrastructure;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.bookmark.domain.BookmarkRepository;
import gravit.code.problem.dto.response.ProblemDetail;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class BookmarkRepositoryImpl implements BookmarkRepository {

    private final BookmarkJpaRepository bookmarkJpaRepository;

    @Override
    public List<ProblemDetail> findBookmarkedProblemDetailByUnitIdAndUserId(
            long unitId,
            long userId
    ) {
        return bookmarkJpaRepository.findBookmarkedProblemDetailByUnitIdAndUserId(unitId, userId);
    }

    @Override
    public void save(Bookmark bookmark) {
        bookmarkJpaRepository.save(bookmark);
    }

    @Override
    public boolean existsByProblemIdAndUserId(
            long problemId,
            long userId
    ) {
        return bookmarkJpaRepository.existsByProblemIdAndUserId(problemId, userId);
    }

    @Override
    public void deleteByProblemIdAndUserId(
            long problemId,
            long userId
    ) {
        bookmarkJpaRepository.deleteByProblemIdAndUserId(problemId, userId);
    }
}
