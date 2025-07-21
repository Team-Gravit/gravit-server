package gravit.code.lessonProgress.service;

import gravit.code.lessonProgress.domain.LessonProgress;
import gravit.code.lessonProgress.repository.LessonProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LessonProgressService {

    private final LessonProgressRepository lessonProgressRepository;

    public Boolean updateLessonProgress(Long userId, Long lessonId, Long problemSize){

        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(lessonId, userId);

        lessonProgress.updateCompletedProblems(problemSize);

        return lessonProgress.isLessonCompleted();
    }
}
