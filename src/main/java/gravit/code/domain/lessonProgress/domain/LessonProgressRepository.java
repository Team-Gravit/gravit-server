package gravit.code.domain.lessonProgress.domain;

import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonProgressRepository {

    LessonProgress save(LessonProgress lessonProgress);

    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);

    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(@Param("userId") Long userId, @Param("unitId") Long unitId);
}
