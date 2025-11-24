package gravit.code.bookmark.infrastructure;

import gravit.code.bookmark.domain.Bookmark;
import gravit.code.bookmark.domain.BookmarkRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class BookmarkRepositoryImpl implements BookmarkRepository {

    private final BookmarkJpaRepository bookmarkJpaRepository;


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
