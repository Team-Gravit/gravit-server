package gravit.code.domain.learning.service;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.lessonProgress.service.LessonProgressService;
import gravit.code.domain.recentLearning.service.RecentLearningService;
import gravit.code.domain.unitProgress.service.UnitProgressService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LearningService {

    private final RecentLearningService recentLearningService;

    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final LessonProgressService lessonProgressService;

    public void initLearningProgress(Long userId, Long chapterId, Long unitId, Long lessonId){
        if (Boolean.TRUE.equals(lessonProgressService.createLessonProgress(userId, lessonId)))
            if(Boolean.TRUE.equals(unitProgressService.createUnitProgress(userId, unitId)))
                chapterProgressService.createChapterProgress(userId, chapterId);
    }

    @Async("learningAsync")
    public void updateRecentLearning(Long userId, Long chapterId){
        ChapterInfo chapterInfo = chapterProgressService.getChapterInfo(userId, chapterId);

        recentLearningService.updateRecentLearning(userId, chapterInfo);
    }
}
