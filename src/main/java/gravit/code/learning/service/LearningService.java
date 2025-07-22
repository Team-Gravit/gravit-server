package gravit.code.learning.service;

import gravit.code.chapterProgress.service.ChapterProgressService;
import gravit.code.lessonProgress.service.LessonProgressService;
import gravit.code.unitProgress.service.UnitProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LearningService {

    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final LessonProgressService lessonProgressService;

    @Async("learningAsync")
    public void initLearningProgress(Long userId, Long chapterId, Long unitId, Long lessonId){
        if (lessonProgressService.createLessonProgress(userId, lessonId))
            if(unitProgressService.createUnitProgress(userId, unitId))
                chapterProgressService.createChapterProgress(userId, chapterId);
    }
}
