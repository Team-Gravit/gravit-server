package gravit.code.unitProgress.service;

import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import gravit.code.unitProgress.domain.UnitProgress;
import gravit.code.unitProgress.repository.UnitProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UnitProgressService {

    private final UnitProgressRepository unitProgressRepository;

    public Boolean updateUnitProgress(Long userId, Long unitId){

        UnitProgress unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId,userId)
                        .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_PROGRESS_NOT_FOUND));

        unitProgress.updateCompletedLessons();

        return unitProgress.isUnitCompleted();
    }
}
