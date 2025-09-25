package gravit.code.progress.service;

import gravit.code.learning.domain.Lesson;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.LessonProgressRepository;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonRepository lessonRepository;
    private final LessonProgressRepository lessonProgressRepository;

    @Transactional
    public void updateLessonProgress(
            long lessonId,
            long userId,
            int learningTime
    ){

        Lesson targetLesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(lessonId, userId)
                .orElseGet(() -> LessonProgress.create(userId, targetLesson.getId()));

        lessonProgress.updateStatus(learningTime);

        lessonProgressRepository.save(lessonProgress);
    }

    @Transactional(readOnly = true)
    public List<LessonProgressSummaryResponse> getLessonProgressSummaries(
            long unitId,
            long userId
    ){
        return lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }
}
