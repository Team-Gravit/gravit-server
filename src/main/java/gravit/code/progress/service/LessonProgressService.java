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

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonRepository lessonRepository;
    private final LessonProgressRepository lessonProgressRepository;

    public void updateLessonProgressStatus(Long lessonId, Long userId){

        Lesson targetLesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(lessonId, userId)
                .orElseGet(() -> LessonProgress.create(userId, targetLesson.getId()));

        lessonProgress.updateStatus();

        lessonProgressRepository.save(lessonProgress);
    }

    public List<LessonProgressSummaryResponse> getLessonProgressSummaries(Long unitId, Long userId){
        return lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }
}
