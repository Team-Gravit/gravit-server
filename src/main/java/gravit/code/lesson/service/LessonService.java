package gravit.code.lesson.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.lesson.dto.response.LessonSummary;
import gravit.code.lesson.domain.LessonRepository;
import gravit.code.lesson.domain.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonService {
    private final LessonRepository lessonRepository;
    private final LessonSubmissionRepository lessonSubmissionRepository;

    @Transactional(readOnly = true)
    public LearningIds getLearningIdsByLessonId(long lessonId){
        return lessonRepository.findLearningIdsByLessonId(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public double getProgressRateByChapterId(
            long chapterId,
            long userId
    ) {
        int totalLessonCount = lessonRepository.countTotalLessonByChapterId(chapterId);
        int solvedLessonCount = lessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId(chapterId, userId);

        return (double) solvedLessonCount / totalLessonCount;
    }

    @Transactional(readOnly = true)
    public double getProgressRateByUnitId(
            long unitId,
            long userId
    ) {
        int totalLessonCount = lessonRepository.countTotalLessonByUnitId(unitId);
        int solvedLessonCount = lessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId(unitId, userId);

        return (double) solvedLessonCount / totalLessonCount;
    }

    @Transactional(readOnly = true)
    public List<LessonSummary> getAllLessonSummaryByUnitId(long unitId, long userId) {
        return lessonRepository.findAllLessonSummaryByUnitId(unitId, userId);
    }
}
