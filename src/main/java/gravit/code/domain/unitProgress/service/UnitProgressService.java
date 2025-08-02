package gravit.code.domain.unitProgress.service;

import gravit.code.domain.unit.domain.Unit;
import gravit.code.domain.unit.domain.UnitRepository;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.domain.UnitProgressRepository;
import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
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

    public Boolean updateUnitProgress(Long unitId, Long userId){

        Unit targetUnit = unitRepository.findById(unitId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));

        UnitProgress unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId, userId)
                .orElseGet(() -> UnitProgress.create(targetUnit.getTotalLessons(), userId, unitId));

        unitProgress.updateCompletedLessons();

        unitProgressRepository.save(unitProgress);

        return unitProgress.isComplete();
    }

    public List<UnitProgressDetailResponse> findAllUnitProgress(Long chapterId, Long userId){

        List<UnitProgressDetailResponse> unitProgressDetailResponses = unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId);

        if (unitProgressDetailResponses.isEmpty())
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);

        return unitProgressDetailResponses;
    }
}
