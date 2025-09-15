package gravit.code.progress.domain;

import gravit.code.progress.dto.response.UnitProgressDetailResponse;

import java.util.List;
import java.util.Optional;

public interface UnitProgressRepository {

    UnitProgress save(UnitProgress unitProgress);

    Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId);

    List<UnitProgressDetailResponse> findAllUnitProgressDetailsByChapterIdAndUserId(Long chapterId, Long userId);

}
