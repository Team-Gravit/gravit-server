package gravit.code.progress.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.LessonProgressRepository;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonProgressRepository lessonProgressRepository;
    private final LessonRepository lessonRepository;

    @Transactional
    public LessonProgress getLessonProgressAndUpdateStatus(
            long lessonId,
            long userId,
            int learningTime
    ) {
        if(!lessonRepository.existsById(lessonId))
            throw new RestApiException(CustomErrorCode.LESSON_NOT_FOUND);

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(lessonId, userId)
                .orElseGet(() -> LessonProgress.create(userId, lessonId));

        lessonProgress.updateStatus(learningTime);

        return lessonProgressRepository.save(lessonProgress);
    }

    @Transactional(readOnly = true)
    public List<LessonProgressSummaryResponse> getLessonProgressSummaries(
            long unitId,
            long userId
    ){
        return lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }

}
