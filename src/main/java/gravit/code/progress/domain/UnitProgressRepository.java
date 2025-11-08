package gravit.code.progress.domain;

import gravit.code.progress.dto.response.UnitProgressDetailResponse;

import java.util.List;
import java.util.Optional;

public interface UnitProgressRepository {
    UnitProgress save(UnitProgress unitProgress);
    Optional<UnitProgress> findByUnitIdAndUserId(
            long unitId,
            long userId
    );
    List<UnitProgressDetailResponse> findAllUnitProgressDetailsByChapterIdAndUserId(
            long chapterId,
            long userId
    );
    void saveAll(List<UnitProgress> unitProgresses);
}
