package gravit.code.learning.facade;

import gravit.code.chapterProgress.ChapterInfoResponse;
import gravit.code.chapterProgress.service.ChapterProgressService;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.service.LearningService;
import gravit.code.lessonProgress.dto.response.LessonInfo;
import gravit.code.lessonProgress.service.LessonProgressService;
import gravit.code.problemProgress.service.ProblemProgressService;
import gravit.code.unitProgress.dto.response.UnitInfo;
import gravit.code.unitProgress.dto.response.UnitPageResponse;
import gravit.code.unitProgress.service.UnitProgressService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LearningFacade {

    private final UserService userService;
    private final LearningService learningService;
    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final LessonProgressService lessonProgressService;
    private final ProblemProgressService problemProgressService;

    @Transactional
    public UserLevelResponse saveLearningProgress(Long userId, LearningResultSaveRequest request){

        learningService.initLearningProgress(userId, request.chapterId(), request.unitId(), request.lessonId());

        problemProgressService.saveProblemResults(userId, request.problemResults());

        lessonProgressService.updateLessonProgressStatus(userId, request.lessonId());

        if(Boolean.TRUE.equals(unitProgressService.updateUnitProgress(userId, request.unitId())))
            chapterProgressService.updateChapterProgress(userId, request.chapterId());

        return userService.updateUserLevel(userId);
    }

    @Transactional(readOnly = true)
    public List<ChapterInfoResponse> getAllChapters(Long userId){
        return chapterProgressService.findChaptersWithProgressByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<UnitPageResponse> getAllUnits(Long userId, Long chapterId){
        List<UnitInfo> unitInfos = unitProgressService.getUnitInfosByChapterId(userId, chapterId);

        return unitInfos.stream()
                .map(unitInfo -> {
                    List<LessonInfo> lessonInfos = lessonProgressService.getLessonInfosByUnitId(userId, unitInfo.unitId());

                    return UnitPageResponse.create(unitInfo, lessonInfos);
                })
                .toList();
    }
}
