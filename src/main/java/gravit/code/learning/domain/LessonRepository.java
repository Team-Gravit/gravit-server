package gravit.code.learning.domain;

import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;

import java.util.List;
import java.util.Optional;

public interface LessonRepository {
    Lesson save(Lesson lesson);
    Optional<Lesson> findById(Long lessonId);
    long count();
    boolean existsById(Long lessonId);
    Optional<LearningIds> findLearningIdsByLessonId(long lessonId);
    Optional<LearningAdditionalInfo> findLearningAdditionalInfoByLessonId(long lessonId);
    void saveAll(List<Lesson> lessons);
}
