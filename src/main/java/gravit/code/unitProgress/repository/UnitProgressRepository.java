package gravit.code.unitProgress.repository;

import gravit.code.unitProgress.domain.UnitProgress;
import gravit.code.unitProgress.dto.response.UnitInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UnitProgressRepository extends JpaRepository<UnitProgress,Long> {
    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);

    boolean existsByUnitIdAndUserId(Long unitId, Long userId);

    @Query("""
        SELECT up.totalLessons
        FROM UnitProgress up
        WHERE up.unitId = :unitId
    """)
    Long getTotalLessonsByUnitId(Long unitId);

    @Query("""
        SELECT new gravit.code.unitProgress.dto.response.UnitInfo(u.id, u.name, u.totalLessons, COALESCE(CAST(up.completedLessons as long), 0L))
        FROM Unit u
        LEFT JOIN UnitProgress up ON u.id = up.unitId AND up.userId = :userId
        WHERE u.chapterId = :chapterId
        ORDER BY u.id
    """)
    List<UnitInfo> findUnitsWithProgressByChapterId(@Param("userId") Long userId, @Param("chapterId") Long chapterId);
}
