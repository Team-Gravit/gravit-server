package gravit.code.lesson.domain;

import gravit.code.learning.dto.common.LearningIds;
import gravit.code.lesson.dto.response.LessonSummary;

import java.util.List;
import java.util.Optional;

public interface LessonRepository {
    Optional<Lesson> findById(long lessonId);
    Optional<LearningIds> findLearningIdsByLessonId(long lessonId);
    List<LessonSummary> findAllLessonSummaryByUnitId(
            long unitId,
            long userId
    );
    long count();
    int countTotalLessonByChapterId(long chapterId);
    int countTotalLessonByUnitId(long unitId);
    boolean existsById(long lessonId);
    Lesson save(Lesson lesson);
    void saveAll(List<Lesson> lessons);
}
