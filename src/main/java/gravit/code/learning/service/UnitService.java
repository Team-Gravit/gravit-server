package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.UnitRepository;
import gravit.code.learning.dto.response.UnitSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UnitService {

    private final UnitRepository unitRepository;

    @Transactional(readOnly = true)
    public List<UnitSummary> getAllUnitSummaryByChapterId(long chapterId) {
        return unitRepository.findAllUnitSummaryByChapterId(chapterId);
    }

    @Transactional(readOnly = true)
    public UnitSummary getUnitSummaryLessonId(long lessonId) {
        return unitRepository.findUnitSummaryByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));
    }
}
