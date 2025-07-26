package gravit.code.domain.chapter.infrastructure;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ChapterJpaRepository extends JpaRepository<Chapter, Long> {
    @Query("""
        SELECT new gravit.code.domain.learning.dto.response.RecentLearningInfo(c.id, c.name, c.description, c.totalUnits, cp.completedUnits)
        FROM ProblemProgress pp
        JOIN Problem p ON pp.problemId = p.id
        JOIN Lesson l ON p.lessonId = l.id
        JOIN Unit u ON l.unitId = u.id
        JOIN Chapter c ON u.chapterId = c.id
        LEFT JOIN ChapterProgress cp ON c.id = cp.chapterId AND cp.userId = :userId
        WHERE pp.userId = :userId
        ORDER BY pp.createdAt DESC
        LIMIT 1
    """)
    Optional<RecentLearningInfo> findRecentLearningChapter(@Param("userId") Long userId);

    @Query("""
        SELECT c.totalUnits
        FROM Chapter c
        WHERE c.id = :chapterId
    """)
    Long getTotalUnitsByChapterId(@Param("chapterId") Long chapterId);
}
