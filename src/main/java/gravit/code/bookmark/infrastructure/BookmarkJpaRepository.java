package gravit.code.bookmark.infrastructure;

import gravit.code.bookmark.domain.Bookmark;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BookmarkJpaRepository extends JpaRepository<Bookmark, Long> {

    @Modifying
    @Query("""
        DELETE
        FROM Bookmark b
        WHERE b.problemId = :problemId AND b.userId = :userId
    """)
    void deleteByProblemIdAndUserId(
            @Param("problemId") long problemId,
            @Param("userId") long userId
    );

    boolean existsByProblemIdAndUserId(long problemId, long userId);
}
