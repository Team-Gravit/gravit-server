package gravit.code.domain.chapterProgress.infrastructure;

import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse;
import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChapterProgressJpaRepository extends JpaRepository<ChapterProgress, Long> {

    Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId);

    @Query("""
        SELECT new gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse(c.id, c.name, c.description, c.totalUnits, COALESCE(CAST(cp.completedUnits as long), 0L))
        FROM Chapter c
        LEFT JOIN ChapterProgress cp ON c.id = cp.chapterId AND cp.userId = :userId
        WHERE EXISTS (SELECT 1 FROM User u WHERE u.id = :userId)
        ORDER BY c.id
    """)
    List<ChapterProgressDetailResponse> findAllChapterProgressDetailByUserId(@Param("userId") Long userId);

    @Query("""
        SELECT new gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse(c.id, c.name, c.totalUnits, cp.completedUnits)
        FROM ChapterProgress cp
        JOIN Chapter c ON cp.chapterId = c.id
        WHERE cp.chapterId = :chapterId AND cp.userId = :userId
    """)
    Optional<ChapterSummaryResponse> findChapterSummaryByChapterIdAndUserId(@Param("chapterId") Long chapterId, @Param("userId") Long userId);
}
