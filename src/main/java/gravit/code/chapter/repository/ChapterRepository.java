package gravit.code.chapter.repository;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.response.ChapterSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChapterRepository extends JpaRepository<Chapter, Long> {

    Optional<Chapter> findById(long chapterId);

    @Query("""
        SELECT new gravit.code.chapter.dto.response.ChapterSummary(c.id, c.title, c.description)
        FROM Chapter c
    """)
    List<ChapterSummary> findAllChapterSummary();

    @Query("""
        SELECT new gravit.code.chapter.dto.response.ChapterSummary(c.id, c.title, c.description)
        FROM Chapter c
        WHERE c.id = :chapterId
    """)
    Optional<ChapterSummary> findChapterSummaryByChapterId(@Param("chapterId") long chapterId);

}
