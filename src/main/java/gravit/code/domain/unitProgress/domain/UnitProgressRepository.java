package gravit.code.domain.unitProgress.domain;

import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UnitProgressRepository {

    UnitProgress save(UnitProgress unitProgress);

    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);

    List<UnitProgressDetailResponse> findAllUnitProgressDetailsByChapterIdAndUserId(@Param("chapterId") Long chapterId, @Param("userId") Long userId);

}
