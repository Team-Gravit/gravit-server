package gravit.code.learning.domain;

import gravit.code.learning.dto.response.LessonProgressSummaryResponse;

import java.util.List;
import java.util.Optional;

public interface LessonSubmissionRepository {
    LessonSubmission save(LessonSubmission lessonSubmission);
    Optional<LessonSubmission> findByLessonIdAndUserId(
            long lessonId,
            long userId
    );
    List<LessonProgressSummaryResponse> findLessonProgressSummaryByUnitIdAndUserId(
            long unitId,
            long userId
    );
    long countByUserId(long userId);
    void saveAll(List<LessonSubmission> lessonSubmissions);
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
    boolean existsByLessonIdAndUserId(long lessonId, long userId);
}