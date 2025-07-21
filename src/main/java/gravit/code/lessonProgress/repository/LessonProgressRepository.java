package gravit.code.lessonProgress.repository;

import gravit.code.lessonProgress.domain.LessonProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonProgressRepository extends JpaRepository<LessonProgress,Long> {
    LessonProgress findByLessonIdAndUserId(Long lessonId, Long userId);
}
