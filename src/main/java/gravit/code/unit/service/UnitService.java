package gravit.code.unit.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.domain.UnitRepository;
import gravit.code.unit.dto.response.UnitSummary;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UnitService {

    private final UnitRepository unitRepository;

    @Transactional(readOnly = true)
    public List<UnitSummary> getAllUnitSummaryByChapterId(long chapterId) {
        return unitRepository.findAllUnitSummaryByChapterId(chapterId);
    }

    @Transactional(readOnly = true)
    public UnitSummary getUnitSummaryByUnitId(long unitId){
        return unitRepository.findUnitSummaryById(unitId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public UnitSummary getUnitSummaryByLessonId(long lessonId) {
        return unitRepository.findUnitSummaryByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));
    }
}
