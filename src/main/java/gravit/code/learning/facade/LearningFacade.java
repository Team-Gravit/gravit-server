package gravit.code.learning.facade;

import gravit.code.chapterProgress.service.ChapterProgressService;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.service.LearningService;
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
    private final LearningService learningService;
    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final ProblemProgressService problemProgressService;

    @Transactional
    public UserLevelResponse saveLearningProgress(Long userId, LearningResultSaveRequest request){

        learningService.initLearningProgress(userId, request.chapterId(), request.unitId(), request.lessonId());

        problemProgressService.saveProblemResults(userId, request.problemResults());

        if(unitProgressService.updateUnitProgress(userId, request.unitId()))
            chapterProgressService.updateChapterProgress(userId, request.chapterId());

        return userService.updateUserLevel(userId);
    }
}
