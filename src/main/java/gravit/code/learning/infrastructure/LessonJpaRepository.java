package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonJpaRepository extends JpaRepository<Lesson, Long> {
}
