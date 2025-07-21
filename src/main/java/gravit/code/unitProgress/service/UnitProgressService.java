package gravit.code.unitProgress.service;

import gravit.code.unitProgress.domain.UnitProgress;
import gravit.code.unitProgress.repository.UnitProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UnitProgressService {

    private final UnitProgressRepository unitProgressRepository;

    public Boolean updateUnitProgress(Long userId, Long unitId){

        UnitProgress unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId,userId);

        unitProgress.updateCompletedLessons();

        return unitProgress.isUnitCompleted();
    }
}
