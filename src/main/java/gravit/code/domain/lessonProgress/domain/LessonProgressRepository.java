package gravit.code.domain.lessonProgress.domain;

import gravit.code.domain.lessonProgress.dto.response.LessonInfo;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonProgressRepository {

    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);

    boolean existsByLessonIdAndUserId(Long lessonId, Long userId);

    List<LessonInfo> findLessonsWithProgressByUnitId(@Param("userId") Long userId, @Param("unitId") Long unitId);

    LessonProgress save(LessonProgress lessonProgress);
}
