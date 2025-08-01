package gravit.code.domain.chapter.infrastructure;

import gravit.code.domain.chapter.domain.Chapter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChapterJpaRepository extends JpaRepository<Chapter, Long> {

    @Query("""
        SELECT c.totalUnits
        FROM Chapter c
        WHERE c.id = :chapterId
    """)
    Long findTotalUnitsByChapterId(@Param("chapterId") Long chapterId);
}
