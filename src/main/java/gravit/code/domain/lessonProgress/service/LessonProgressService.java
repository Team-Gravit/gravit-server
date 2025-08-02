package gravit.code.domain.lessonProgress.service;

import gravit.code.domain.lessonProgress.domain.LessonProgress;
import gravit.code.domain.lessonProgress.domain.LessonProgressRepository;
import gravit.code.domain.lessonProgress.dto.response.LessonInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonProgressRepository lessonProgressRepository;

    public void updateLessonProgressStatus(Long userId, Long lessonId){

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(userId, lessonId)
                .orElseGet(() -> LessonProgress.create(userId, lessonId, false));

        lessonProgress.updateProgressStatus();
    }

    public List<LessonInfo> getAllLessonsWithProgress(Long userId, Long unitId){
        return lessonProgressRepository.findAllLessonsWithProgress(userId, unitId);
    }
}
