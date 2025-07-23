package gravit.code.domain.unitProgress.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.dto.response.UnitInfo;
import gravit.code.domain.unitProgress.domain.UnitProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

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

    public Boolean createUnitProgress(Long userId, Long unitId){
        if (unitProgressRepository.existsByUnitIdAndUserId(unitId,userId)) {
            return false;
        }else{
            Long totalLessons = unitProgressRepository.getTotalLessonsByUnitId(unitId);
            UnitProgress unitProgress = UnitProgress.create(totalLessons, userId, unitId);
            unitProgressRepository.save(unitProgress);
            return true;
        }
    }

    public List<UnitInfo> getUnitInfosByChapterId(Long userId, Long chapterId){
        return unitProgressRepository.findUnitsWithProgressByChapterId(userId, chapterId);
    }
}
