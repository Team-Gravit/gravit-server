package gravit.code.chapterProgress.repository;

import gravit.code.chapterProgress.ChapterInfoResponse;
import gravit.code.chapterProgress.domain.ChapterProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChapterProgressRepository extends JpaRepository<ChapterProgress,Long> {
    Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId);

    boolean existsByChapterIdAndUserId(Long chapterId, Long userId);

    @Query("""
        SELECT cp.totalUnits
        FROM ChapterProgress cp
        WHERE cp.chapterId = :chapterId
    """)
    Long getTotalUnitsByChapterId(Long chapterId);

    @Query("""
        SELECT new gravit.code.chapter.dto.response.ChapterInfoResponse(c.id, c.name, c.description, c.totalUnits, COALESCE(CAST(cp.completedUnits as long), 0L))
        FROM Chapter c
        LEFT JOIN ChapterProgress cp ON c.id = cp.chapterId AND cp.userId = :userId
        ORDER BY c.id
    """)
    List<ChapterInfoResponse> findAllChapterInfoByUserId(@Param("userId") Long userId);
}
