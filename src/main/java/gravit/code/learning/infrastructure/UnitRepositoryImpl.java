package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Unit;
import gravit.code.learning.domain.UnitRepository;
import gravit.code.learning.dto.response.UnitSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UnitRepositoryImpl implements UnitRepository {

    private final UnitJpaRepository unitJpaRepository;

    @Override
    public Unit save(Unit unit) {
        return unitJpaRepository.save(unit);
    }

    @Override
    public Optional<Unit> findById(Long unitId) {
        return unitJpaRepository.findById(unitId);
    }

    @Override
    public void saveAll(List<Unit> units){
        unitJpaRepository.saveAll(units);
    }

    @Override
    public List<UnitSummary> findAllUnitSummaryByChapterId(long chapterId) {
        return unitJpaRepository.findAllUnitSummaryByChapterId(chapterId);
    }

    @Override
    public Optional<UnitSummary> findUnitSummaryByLessonId(long lessonId) {
        return unitJpaRepository.findUnitSummaryByLessonId(lessonId);
    }
}
