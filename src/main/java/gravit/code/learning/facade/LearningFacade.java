package gravit.code.learning.facade;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.request.RecentLearningEventDto;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.service.ProblemService;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.UnitProgress;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import gravit.code.progress.dto.response.UnitPageResponse;
import gravit.code.progress.dto.response.UnitProgressDetailResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.progress.service.LessonProgressService;
import gravit.code.progress.service.ProblemProgressService;
import gravit.code.progress.service.UnitProgressService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
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
        publisher.publishEvent(new LessonCompletedEvent(userId, 20));

        return userService.updateUserLevelAndXp(userId);
    }
}
