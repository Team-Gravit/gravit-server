package gravit.code.progress.infrastructure;

import gravit.code.progress.domain.UnitProgress;
import gravit.code.progress.domain.UnitProgressRepository;
import gravit.code.progress.dto.response.UnitProgressDetailResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UnitProgressRepositoryImpl implements UnitProgressRepository {

    private final UnitProgressJpaRepository unitProgressJpaRepository;

    @Override
    public Optional<UnitProgress> findByUnitIdAndUserId(Long unitId, Long userId){
        return unitProgressJpaRepository.findByUnitIdAndUserId(unitId, userId);
    }

    @Override
    public List<UnitProgressDetailResponse> findAllUnitProgressDetailsByChapterIdAndUserId(@Param("chapterId") Long chapterId, @Param("userId") Long userId){
        return  unitProgressJpaRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId);
    }

    @Override
    public UnitProgress save(UnitProgress unitProgress) {
        return unitProgressJpaRepository.save(unitProgress);
    }
}
