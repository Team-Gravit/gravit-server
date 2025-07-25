package gravit.code.domain.unitProgress.service;

import gravit.code.domain.unit.domain.UnitRepository;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.domain.UnitProgressRepository;
import gravit.code.domain.unitProgress.dto.response.UnitInfo;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UnitProgressService {

    private final UnitRepository unitRepository;
    private final UnitProgressRepository unitProgressRepository;

    public Boolean updateUnitProgress(Long userId, Long unitId){

        UnitProgress unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId,userId)
                        .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_PROGRESS_NOT_FOUND));

        unitProgress.updateCompletedLessons();

        return unitProgress.isUnitCompleted();
    }

    public Boolean createUnitProgress(Long userId, Long unitId){
        if (unitProgressRepository.existsByUnitIdAndUserId(unitId,userId)) {
            return false;
        }else{
            Long totalLessons = unitRepository.getTotalLessonsByUnitId(unitId);
            UnitProgress unitProgress = UnitProgress.create(totalLessons, userId, unitId);
            unitProgressRepository.save(unitProgress);
            return true;
        }
    }

    public List<UnitInfo> getAllUnitsWithProgress(Long userId, Long chapterId){
        return unitProgressRepository.findAllUnitsWithProgress(userId, chapterId);
    }
}
