package gravit.code.learning.service;

import gravit.code.lesson.domain.LessonRepository;
import gravit.code.lesson.domain.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LearningProgressRateService {

    private final LessonRepository lessonRepository;
    private final LessonSubmissionRepository lessonSubmissionRepository;

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
    public int getPlanetConquestRate(
            long userId
    ) {
        long totalLesson = lessonRepository.count();
        long solvedLesson = lessonSubmissionRepository.countByUserId(userId);

        return Math.toIntExact(
                Math.round(((double) solvedLesson / totalLesson) * 100)
        );
    }

}
