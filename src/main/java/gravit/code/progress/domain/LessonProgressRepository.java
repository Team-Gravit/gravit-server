package gravit.code.progress.domain;

import gravit.code.progress.dto.response.LessonProgressSummaryResponse;

import java.util.List;
import java.util.Optional;

public interface LessonProgressRepository {

    LessonProgress save(LessonProgress lessonProgress);
    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);
    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(Long unitId, Long userId);
    Long countByUserId(Long userId);
}
