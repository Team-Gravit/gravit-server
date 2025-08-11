package gravit.code.domain.learning.facade;

import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.learning.dto.request.LearningResultSaveRequest;
import gravit.code.domain.learning.dto.request.RecentLearningEventDto;
import gravit.code.domain.lesson.dto.response.LessonResponse;
import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import gravit.code.domain.lessonProgress.service.LessonProgressService;
import gravit.code.domain.problem.service.ProblemService;
import gravit.code.domain.problemProgress.service.ProblemProgressService;
import gravit.code.domain.unitProgress.domain.UnitProgress;
import gravit.code.domain.unitProgress.dto.response.UnitPageResponse;
import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
import gravit.code.domain.unitProgress.service.UnitProgressService;
import gravit.code.domain.user.dto.response.UserLevelResponse;
import gravit.code.domain.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LearningFacade {

    private final ApplicationEventPublisher publisher;

    private final UserService userService;
    private final ProblemService problemService;

    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final LessonProgressService lessonProgressService;
    private final ProblemProgressService problemProgressService;

    @Transactional(readOnly = true)
    public List<ChapterProgressDetailResponse> getAllChapters(Long userId){
        return chapterProgressService.getChapterProgressDetails(userId);
    }

    @Transactional(readOnly = true)
    public List<UnitPageResponse> getAllUnitsInChapter(Long userId, Long chapterId){
        List<UnitProgressDetailResponse> unitProgressDetailResponses = unitProgressService.findAllUnitProgress(chapterId, userId);

        return unitProgressDetailResponses.stream()
                .map(unitProgressDetailResponse -> {
                    List<LessonProgressSummaryResponse> lessonProgressSummaryResponses = lessonProgressService.getLessonProgressSummaries(unitProgressDetailResponse.unitId(), userId);

                    return UnitPageResponse.create(unitProgressDetailResponse, lessonProgressSummaryResponses);
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemsInLesson(Long lessonId){
        return LessonResponse.create(problemService.getAllProblem(lessonId));
    }

    @Transactional
    public UserLevelResponse saveLearningResult(Long userId, LearningResultSaveRequest request){

        ChapterProgress chapterProgress = chapterProgressService.ensureChapterProgress(request.chapterId(), userId);
        UnitProgress unitProgress = unitProgressService.ensureUnitProgress(request.unitId(), userId);

        problemProgressService.saveProblemResults(userId, request.problemResults());

        lessonProgressService.updateLessonProgressStatus(request.lessonId(), userId);

        if(Boolean.TRUE.equals(unitProgressService.updateUnitProgress(unitProgress)))
            chapterProgressService.updateChapterProgress(chapterProgress);

        publisher.publishEvent(new RecentLearningEventDto(userId, request.chapterId()));

        return userService.updateUserLevelAndXp(userId);
    }
}
