package gravit.code.learning.domain;

import gravit.code.learning.dto.response.UnitSummary;

import java.util.List;
import java.util.Optional;

public interface UnitRepository {
    Optional<Unit> findById(long unitId);
    List<UnitSummary> findAllUnitSummaryByChapterId(long chapterId);
    Optional<UnitSummary> findUnitSummaryByLessonId(long lessonId);
    Unit save(Unit unit);
    void saveAll(List<Unit> units);
}
