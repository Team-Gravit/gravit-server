package gravit.code.lessonProgress.service;

import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import gravit.code.lessonProgress.domain.LessonProgress;
import gravit.code.lessonProgress.dto.response.LessonInfo;
import gravit.code.lessonProgress.repository.LessonProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonProgressRepository lessonProgressRepository;

    public Boolean createLessonProgress(Long userId, Long lessonId){
        if(lessonProgressRepository.existsByLessonIdAndUserId(lessonId, userId)){
            return false;
        }else{
            LessonProgress lessonProgress = LessonProgress.create(userId, lessonId, false);
            lessonProgressRepository.save(lessonProgress);
            return true;
        }
    }

    public void updateLessonProgressStatus(Long userId, Long lessonId){

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(userId, lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_PROGRESS_NOT_FOUND));

        lessonProgress.updateProgressStatus();
    }

    public List<LessonInfo> getLessonInfosByUnitId(Long userId, Long unitId){
        return lessonProgressRepository.findLessonsWithProgressByUnitId(userId, unitId);
    }
}
