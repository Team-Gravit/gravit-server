package gravit.code.bookmark.domain;

public interface BookmarkRepository {
    void save(Bookmark bookmark);
    void deleteByProblemIdAndUserId(
            long problemId,
            long userId
    );
    boolean existsByProblemIdAndUserId(long userId, long l);
}
