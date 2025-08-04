package gravit.code.domain.lessonProgress.service;

import gravit.code.domain.lesson.domain.Lesson;
import gravit.code.domain.lesson.domain.LessonRepository;
import gravit.code.domain.lessonProgress.domain.LessonProgress;
import gravit.code.domain.lessonProgress.domain.LessonProgressRepository;
import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
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
                .orElseGet(() -> LessonProgress.create(userId, targetLesson.getId(), false));

        lessonProgress.updateStatus();

        lessonProgressRepository.save(lessonProgress);
    }

    public List<LessonProgressSummaryResponse> getLessonProgressSummaries(Long unitId, Long userId){
        return lessonProgressRepository.findLessonProgressSummaryByUnitIdAndUserId(unitId, userId);
    }
}
