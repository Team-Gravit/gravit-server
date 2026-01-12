package gravit.code.unit.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.unit.repository.UnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UnitQueryService {

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
