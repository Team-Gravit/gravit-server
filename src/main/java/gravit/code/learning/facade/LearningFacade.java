package gravit.code.learning.facade;

import gravit.code.chapterProgress.service.ChapterProgressService;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.lessonProgress.service.LessonProgressService;
import gravit.code.problemProgress.service.ProblemProgressService;
import gravit.code.unitProgress.service.UnitProgressService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LearningFacade {

    private final UserService userService;
    private final ProblemProgressService problemProgressService;
    private final LessonProgressService lessonProgressService;
    private final UnitProgressService unitProgressService;
    private final ChapterProgressService chapterProgressService;

    @Transactional
    public UserLevelResponse saveLearningProgress(Long userId, LearningResultSaveRequest request){

        problemProgressService.saveProblemResults(userId, request.problemResults());

        if(lessonProgressService.updateLessonProgress(userId, request.lessonId(), (long) request.problemResults().size())){
            if(unitProgressService.updateUnitProgress(userId, request.unitId()))
                chapterProgressService.updateChapterProgress(userId, request.chapterId());

        }

        return userService.updateUserLevel(userId);
    }
}
