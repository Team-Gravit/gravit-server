package gravit.code.learning.facade;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.QualifiedSolvedEvent;
import gravit.code.learning.dto.LearningIds;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.service.LessonService;
import gravit.code.learning.service.ProblemService;
import gravit.code.mission.dto.event.LessonMissionEvent;
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
    private final LessonService lessonService;
    private final ProblemService problemService;

    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final LessonProgressService lessonProgressService;
    private final ProblemProgressService problemProgressService;

    @Transactional(readOnly = true)
    public List<ChapterProgressDetailResponse> getAllChapters(long userId){
        return chapterProgressService.getChapterProgressDetails(userId);
    }

    @Transactional(readOnly = true)
    public List<UnitPageResponse> getAllUnitsInChapter(
            long userId,
            long chapterId
    ){
        // 사용자의 유닛 진행도 조회
        List<UnitProgressDetailResponse> unitProgresses = unitProgressService.findAllUnitProgress(chapterId, userId);

        // 유닛 정보 + 유닛 진행도
        return unitProgresses.stream()
                .map(unitProgress -> {
                    List<LessonProgressSummaryResponse> lessonProgressSummaries = lessonProgressService.getLessonProgressSummaries(unitProgress.unitId(), userId);

                    return UnitPageResponse.create(unitProgress, lessonProgressSummaries);
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public LessonResponse getLesson(long lessonId){
        String lessonName = lessonService.findLessonName(lessonId);
        return LessonResponse.create(lessonName, problemService.getAllProblemInLesson(lessonId));
    }

    @Transactional
    public UserLevelResponse saveLearningResult(
            long userId,
            LearningResultSaveRequest request
    ){

        LearningIds learningIds = lessonService.findLearningIdsByLessonId(request.lessonId());

        ChapterProgress chapterProgress = chapterProgressService.ensureChapterProgress(learningIds.chapterId(), userId);
        UnitProgress unitProgress = unitProgressService.ensureUnitProgress(learningIds.unitId(), userId);

        // 문제 풀이 결과 저장
        problemProgressService.saveProblemResults(userId, request.problemResults());

        // lesson, unit, chapter 진행도 업데이트
        lessonProgressService.updateLessonProgress(request.lessonId(), userId, request.learningTime());

        if(unitProgressService.updateUnitProgress(unitProgress))
            chapterProgressService.updateChapterProgress(chapterProgress);

        publisher.publishEvent(new UpdateLearningEvent(userId, learningIds.chapterId()));
        publisher.publishEvent(new LessonCompletedEvent(userId, 20, request.accuracy()));
        publisher.publishEvent(new LessonMissionEvent(userId, request.lessonId(), request.learningTime(), request.accuracy()));
        publisher.publishEvent(new QualifiedSolvedEvent(userId, request.learningTime(), request.accuracy()));

        return userService.updateUserLevelAndXp(userId,20, request.accuracy());
    }
}
