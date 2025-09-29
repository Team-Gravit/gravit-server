package gravit.code.progress.service;

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

    @Transactional
    public LessonProgress getLessonProgressAndUpdateStatus(
            long lessonId,
            long userId,
            int learningTime
    ) {
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
