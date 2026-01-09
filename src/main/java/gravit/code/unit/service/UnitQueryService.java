package gravit.code.unit.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.domain.UnitRepository;
import gravit.code.unit.dto.response.UnitSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UnitQueryService {

    private final UnitRepository unitRepository;

    public List<UnitSummary> getAllUnitSummaryByChapterId(long chapterId) {
        return unitRepository.findAllUnitSummaryByChapterId(chapterId);
    }

    public UnitSummary getUnitSummaryByUnitId(long unitId){
        return unitRepository.findUnitSummaryById(unitId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));
    }

    public UnitSummary getUnitSummaryByLessonId(long lessonId) {
        return unitRepository.findUnitSummaryByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));
    }
}
