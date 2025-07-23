package gravit.code.domain.unitProgress.domain;

import gravit.code.domain.unitProgress.dto.response.UnitInfo;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UnitProgressRepository {
    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);

    boolean existsByUnitIdAndUserId(Long unitId, Long userId);

    Long getTotalLessonsByUnitId(Long unitId);

    List<UnitInfo> findAllUnitsWithProgress(@Param("userId") Long userId, @Param("chapterId") Long chapterId);

    UnitProgress save(UnitProgress unitProgress);
}
