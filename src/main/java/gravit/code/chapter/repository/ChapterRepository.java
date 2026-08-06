package gravit.code.chapter.repository;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.internal.ChapterProgressRowDto;
import gravit.code.chapter.dto.response.ChapterBriefResponse;
import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChapterRepository extends JpaRepository<Chapter, Long> {

    Optional<Chapter> findById(long chapterId);

    @Query("""
        SELECT new gravit.code.chapter.dto.response.ChapterSummaryResponse(c.id, c.title, c.description)
        FROM Chapter c
    """)
    List<ChapterSummaryResponse> findAllChapterSummary();

    @Query("""
        SELECT new gravit.code.chapter.dto.response.ChapterSummaryResponse(c.id, c.title, c.description)
        FROM Chapter c
        WHERE c.id = :chapterId
    """)
    Optional<ChapterSummaryResponse> findChapterSummaryByChapterId(@Param("chapterId") long chapterId);

    @Query("""
        SELECT new gravit.code.chapter.dto.response.ChapterBriefResponse(c.id, c.title)
        FROM Chapter c
        JOIN Unit u ON u.chapterId = c.id
        WHERE u.id = :unitId
    """)
    Optional<ChapterBriefResponse> findChapterBriefByUnitId(@Param("unitId") long unitId);

    @Query("""
        SELECT new gravit.code.chapter.dto.internal.ChapterProgressRowDto(
            c.id, COUNT(DISTINCT l.id), COUNT(DISTINCT ls.lessonId)
        )
        FROM Chapter c
        LEFT JOIN Unit u ON u.chapterId = c.id
        LEFT JOIN Lesson l ON l.unitId = u.id
        LEFT JOIN LessonSubmission ls ON ls.lessonId = l.id AND ls.userId = :userId
        GROUP BY c.id
    """)
    List<ChapterProgressRowDto> findChapterProgressByUserId(@Param("userId") long userId);
}
