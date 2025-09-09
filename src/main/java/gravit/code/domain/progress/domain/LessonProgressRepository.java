package gravit.code.domain.progress.domain;

import gravit.code.domain.progress.dto.response.LessonProgressSummaryResponse;

import java.util.List;
import java.util.Optional;

public interface LessonProgressRepository {

    LessonProgress save(LessonProgress lessonProgress);

    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);

    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(Long unitId, Long userId);
}
