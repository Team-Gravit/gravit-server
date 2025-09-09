package gravit.code.domain.learning.domain;

import java.util.Optional;

public interface LessonRepository {
    Lesson save(Lesson lesson);
    Optional<Lesson> findById(Long lessonId);
}
