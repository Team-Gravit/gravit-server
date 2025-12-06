package gravit.code.unit.domain;

import gravit.code.unit.dto.response.UnitSummary;

import java.util.List;
import java.util.Optional;

public interface UnitRepository {
    Optional<Unit> findById(long unitId);
    List<UnitSummary> findAllUnitSummaryByChapterId(long chapterId);
    Optional<UnitSummary> findUnitSummaryById(long unitId);
    Optional<UnitSummary> findUnitSummaryByLessonId(long lessonId);
    Unit save(Unit unit);
    void saveAll(List<Unit> units);
    List<Long> findIdsByChapterIdOrderById(long chapterId);
}
