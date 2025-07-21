package gravit.code.chapterProgress.repository;

import gravit.code.chapterProgress.domain.ChapterProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

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
}
