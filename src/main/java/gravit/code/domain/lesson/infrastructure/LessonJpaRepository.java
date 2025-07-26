package gravit.code.domain.lesson.infrastructure;

import gravit.code.domain.lesson.domain.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonJpaRepository extends JpaRepository<Lesson, Long> {
}
