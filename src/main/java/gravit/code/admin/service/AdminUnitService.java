package gravit.code.admin.service;

import gravit.code.admin.dto.request.UnitUpdateRequest;
import gravit.code.admin.dto.response.LessonListItemResponse;
import gravit.code.admin.dto.response.UnitDetailResponse;
import gravit.code.admin.support.AdminPages;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.INVALID_PARAMS;
import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminUnitService {

    private final UnitRepository unitRepository;
    private final LessonRepository lessonRepository;

    @Transactional(readOnly = true)
    public UnitDetailResponse getUnit(long unitId) {
        Unit unit = unitRepository.findById(unitId)
                .orElseThrow(() -> new RestApiException(UNIT_NOT_FOUND));

        long lessonCount = lessonRepository.countTotalLessonByUnitId(unitId);

        return UnitDetailResponse.of(unit, lessonCount);
    }

    @Transactional
    public void updateUnit(
            long unitId,
            UnitUpdateRequest request
    ) {
        Unit unit = unitRepository.findById(unitId)
                .orElseThrow(() -> new RestApiException(UNIT_NOT_FOUND));

        String title = request.title() != null ? request.title() : unit.getTitle();
        String description = request.description() != null ? request.description() : unit.getDescription();

        validateNotBlank(request.title());

        unit.update(title, description);
    }

    @Transactional(readOnly = true)
    public PageResponse<LessonListItemResponse> getLessons(
            long unitId,
            int page
    ) {
        Pageable pageable = AdminPages.of(page, Sort.by(Sort.Direction.ASC, "id"));

        return PageResponse.from(lessonRepository.findByUnitId(unitId, pageable).map(LessonListItemResponse::from));
    }

    private void validateNotBlank(String title) {
        if (title != null && title.isBlank()) {
            throw new RestApiException(INVALID_PARAMS);
        }
    }
}
