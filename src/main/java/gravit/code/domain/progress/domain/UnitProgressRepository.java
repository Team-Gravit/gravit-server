package gravit.code.domain.progress.domain;

import gravit.code.domain.progress.dto.response.UnitProgressDetailResponse;

import java.util.List;
import java.util.Optional;

public interface UnitProgressRepository {

    UnitProgress save(UnitProgress unitProgress);

    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);

    List<UnitProgressDetailResponse> findAllUnitProgressDetailsByChapterIdAndUserId(Long chapterId, Long userId);

}
