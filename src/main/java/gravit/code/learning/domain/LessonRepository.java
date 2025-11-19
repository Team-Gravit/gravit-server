package gravit.code.learning.domain;

import gravit.code.learning.dto.common.LearningAdditionalInfo;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.learning.dto.response.LessonSummary;

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
    int countTotalLessonByChapterId(long chapterId);
    int countTotalLessonByUnitId(long unitId);
    List<LessonSummary> findAllLessonSummaryByUnitId(long unitId, long userId);
}
