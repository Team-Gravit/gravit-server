package gravit.code.lessonProgress.service;

import gravit.code.lessonProgress.domain.LessonProgress;
import gravit.code.lessonProgress.repository.LessonProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonProgressRepository lessonProgressRepository;

    public Boolean createLessonProgress(Long userId, Long lessonId){
        if(lessonProgressRepository.existsByLessonIdAndUserId(lessonId, userId)){
            return false;
        }else{
            LessonProgress lessonProgress = LessonProgress.create(userId, lessonId);
            lessonProgressRepository.save(lessonProgress);
            return true;
        }
    }
}
