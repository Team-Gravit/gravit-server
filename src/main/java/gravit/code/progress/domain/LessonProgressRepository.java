package gravit.code.progress.domain;

import gravit.code.progress.dto.response.LessonProgressSummaryResponse;

import java.util.List;
import java.util.Optional;

public interface LessonProgressRepository {
    LessonProgress save(LessonProgress lessonProgress);
    Optional<LessonProgress> findByLessonIdAndUserId(
            long lessonId,
            long userId
    );
    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(
            long unitId,
            long userId
    );
    long countByUserId(long userId);
}