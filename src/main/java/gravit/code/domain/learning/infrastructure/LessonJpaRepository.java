package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LessonJpaRepository extends JpaRepository<Lesson, Long> {
}
