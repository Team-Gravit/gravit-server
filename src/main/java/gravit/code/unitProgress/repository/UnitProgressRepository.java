package gravit.code.unitProgress.repository;

import gravit.code.unitProgress.domain.UnitProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

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
}
