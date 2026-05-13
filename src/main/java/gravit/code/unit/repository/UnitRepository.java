package gravit.code.unit.repository;

import gravit.code.unit.domain.Unit;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import gravit.code.unit.dto.internal.UnitProgressRowDto;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UnitRepository extends JpaRepository<Unit, Long> {

    Optional<Unit> findById(long unitId);

    @Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummaryResponse(u.id, u.title, u.description)
        FROM Unit u
        WHERE u.chapterId = :chapterId
    """)
    List<UnitSummaryResponse> findAllUnitSummaryByChapterId(@Param("chapterId") long chapterId);

    @Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummaryResponse(u.id, u.title, u.description)
        FROM Unit u
        JOIN Lesson l ON l.unitId = u.id
        WHERE l.id = :lessonId
    """)
    Optional<UnitSummaryResponse> findUnitSummaryByLessonId(@Param("lessonId") long lessonId);

    @Query("""
        SELECT new gravit.code.unit.dto.response.UnitSummaryResponse(u.id, u.title, u.description)
        FROM Unit u
        WHERE u.id = :unitId
    """)
    Optional<UnitSummaryResponse> findUnitSummaryById(@Param("unitId")long unitId);

    @Query("SELECT u.id FROM Unit u WHERE u.chapterId = :chapterId ORDER BY u.id ASC")
    List<Long> findIdsByChapterIdOrderById(@Param("chapterId") long chapterId);

    @Query("""
        SELECT u.id
        FROM Unit u
        ORDER BY u.id ASC
    """)
    List<Long> findAllUnitIdsOrderById();

    @Query("""
        SELECT new gravit.code.unit.dto.internal.UnitProgressRowDto(
            u.id, u.title, COUNT(DISTINCT l.id), COUNT(DISTINCT ls.lessonId)
        )
        FROM Unit u
        LEFT JOIN Lesson l on l.unitId = u.id
        LEFT JOIN LessonSubmission ls on ls.lessonId = l.id AND ls.userId = :userId
        WHERE u.chapterId = :chapterId
        GROUP BY u.id, u.title
        ORDER BY u.id
    """)
    List<UnitProgressRowDto> findUnitProgressByChapterIdAndUserId(
            @Param("chapterId") long chapterId,
            @Param("userId") long userId
    );

    @Query("""
        SELECT new gravit.code.unit.dto.response.RecommendedUnitResponse(
            u.id, u.title, c.id, c.title
        )
        FROM Unit u
        JOIN Chapter c ON c.id = u.chapterId
        WHERE u.id IN :unitIds
        ORDER BY u.id ASC
    """)
    List<RecommendedUnitResponse> findRecommendedUnitsByIds(@Param("unitIds") List<Long> unitIds);
}
