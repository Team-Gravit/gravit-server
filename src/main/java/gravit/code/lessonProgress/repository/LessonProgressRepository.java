package gravit.code.lessonProgress.repository;

import gravit.code.lessonProgress.domain.LessonProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LessonProgressRepository extends JpaRepository<LessonProgress,Long> {
    Optional<LessonProgress> findByLessonIdAndUserId(Long lessonId, Long userId);
}
