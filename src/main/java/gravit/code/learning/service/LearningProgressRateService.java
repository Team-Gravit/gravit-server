package gravit.code.learning.service;

import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LearningProgressRateService {

    private final LessonRepository lessonRepository;
    private final LessonSubmissionRepository lessonSubmissionRepository;

    @Transactional(readOnly = true)
    public double getChapterProgress(
            long chapterId,
            long userId
    ) {
        int solvedLessonCount = lessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId(chapterId, userId);

        if(solvedLessonCount == 0) {
            return 0.0;
        }

        int totalLessonCount = lessonRepository.countTotalLessonByChapterId(chapterId);

        double progressRate = ((double) solvedLessonCount / totalLessonCount) * 100;
        return Math.floor(progressRate);
    }

    @Transactional(readOnly = true)
    public double getUnitProgress(
            long unitId,
            long userId
    ) {
        int solvedLessonCount = lessonSubmissionRepository.countSolvedLessonByUnitIdAndUserId(unitId, userId);

        if(solvedLessonCount == 0) {
            return 0.0;
        }

        int totalLessonCount = lessonRepository.countTotalLessonByUnitId(unitId);

        double progressRate = ((double) solvedLessonCount / totalLessonCount) * 100;
        return Math.floor(progressRate);
    }

    @Transactional(readOnly = true)
    public int getPlanetConquestRate(
            long userId
    ) {
        long solvedLesson = lessonSubmissionRepository.countDistinctLessonByUserId(userId);

        if(solvedLesson == 0) {
            return 0;
        }

        long totalLesson = lessonRepository.count();

        return Math.toIntExact(
                Math.round(((double) solvedLesson / totalLesson) * 100)
        );
    }

    @Transactional(readOnly = true)
    public int getLearningRankPercentile(long userId) {
        return lessonSubmissionRepository.findLearningRateTopPercent(userId)
                .orElse(100);
    }

}
