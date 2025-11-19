package gravit.code.learning.domain;

import gravit.code.learning.dto.response.UnitSummary;

import java.util.List;
import java.util.Optional;

public interface UnitRepository {
    Unit save(Unit unit);
    Optional<Unit> findById(Long unitId);
    void saveAll(List<Unit> units);
    List<UnitSummary> findAllUnitSummaryByChapterId(long chapterId);
    Optional<UnitSummary> findUnitSummaryByLessonId(long lessonId);
}
