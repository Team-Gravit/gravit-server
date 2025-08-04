package gravit.code.domain.unitProgress.infrastructure;

import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UnitProgressJpaRepository extends JpaRepository<UnitProgress,Long> {
    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);

    @Query("""
        SELECT new gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse(u.id, u.name, u.totalLessons, COALESCE(CAST(up.completedLessons as long), 0L))
        FROM Unit u
        LEFT JOIN UnitProgress up ON u.id = up.unitId AND up.userId = :userId
        WHERE u.chapterId = :chapterId AND EXISTS (SELECT 1 FROM User user WHERE user.id = :userId)
        ORDER BY u.id
    """)
    List<UnitProgressDetailResponse> findAllUnitProgressDetailsByChapterIdAndUserId(@Param("chapterId") Long chapterId, @Param("userId") Long userId);

}
