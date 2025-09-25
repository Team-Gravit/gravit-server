package gravit.code.progress.service;

import gravit.code.learning.domain.Unit;
import gravit.code.learning.domain.UnitRepository;
import gravit.code.progress.domain.UnitProgress;
import gravit.code.progress.domain.UnitProgressRepository;
import gravit.code.progress.dto.response.UnitProgressDetailResponse;
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

    public boolean updateUnitProgress(UnitProgress unitProgress){
        unitProgress.updateCompletedLessons();

        return unitProgress.isComplete();
    }

    public List<UnitProgressDetailResponse> findAllUnitProgress(
            long chapterId,
            long userId
    ){

        List<UnitProgressDetailResponse> unitProgressDetailResponses = unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId);

        if (unitProgressDetailResponses.isEmpty())
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);

        return unitProgressDetailResponses;
    }

    public UnitProgress ensureUnitProgress(
            long unitId,
            long userId
    ){

        Unit targetUnit = unitRepository.findById(unitId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));

        UnitProgress unitProgress = unitProgressRepository.findByUnitIdAndUserId(unitId, userId)
                .orElseGet(() -> UnitProgress.create(targetUnit.getTotalLessons(), userId, unitId));

        return unitProgressRepository.save(unitProgress);
    }
}
