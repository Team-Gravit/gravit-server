package gravit.code.lesson.domain;

import java.util.List;
import java.util.Optional;

public interface LessonSubmissionRepository {
    Optional<LessonSubmission> findByLessonIdAndUserId(
            long lessonId,
            long userId
    );
    long countByUserId(long userId);
    int countSolvedLessonByChapterIdAndUserId(
            long chapterId,
            long userId
    );
    int countSolvedLessonByUnitIdAndUserId(
            long unitId,
            long userId
    );
    int countLessonSubmissionByLessonIdAndUserId(
            long lessonId,
            long userId
    );
    boolean existsByLessonIdAndUserId(
            long lessonId,
            long userId
    );
    LessonSubmission save(LessonSubmission lessonSubmission);
    void saveAll(List<LessonSubmission> lessonSubmissions);
}