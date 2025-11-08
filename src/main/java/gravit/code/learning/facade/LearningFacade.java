package gravit.code.learning.facade;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.QualifiedSolvedEvent;
import gravit.code.learning.domain.Chapter;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.response.LearningResultSaveResponse;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.dto.response.UnitPageResponse;
import gravit.code.learning.service.ChapterService;
import gravit.code.learning.service.LessonService;
import gravit.code.learning.service.ProblemService;
import gravit.code.mission.dto.event.LessonMissionEvent;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.UnitProgress;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import gravit.code.progress.dto.response.UnitDetail;
import gravit.code.progress.dto.response.UnitProgressDetailResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.progress.service.LessonProgressService;
import gravit.code.progress.service.ProblemProgressService;
import gravit.code.progress.service.UnitProgressService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Log4j2
@Service
@RequiredArgsConstructor
public class LearningFacade {

    private final ApplicationEventPublisher publisher;

    private final UserService userService;
    private final ChapterService chapterService;
    private final LessonService lessonService;
    private final ProblemService problemService;
    private final UserLeagueService userLeagueService;

    private final ChapterProgressService chapterProgressService;
    private final UnitProgressService unitProgressService;
    private final LessonProgressService lessonProgressService;
    private final ProblemProgressService problemProgressService;

    @Transactional(readOnly = true)
    public List<ChapterProgressDetailResponse> getAllChapters(long userId){
        return chapterProgressService.getChapterProgressDetails(userId);
    }

    @Transactional(readOnly = true)
    public UnitPageResponse getAllUnitsInChapter(
            long userId,
            long chapterId
    ){
        // 유닛 페이지에 들어갈 챕터 조회
        Chapter chapter = chapterService.getChapterById(chapterId);

        // 사용자의 유닛 진행도 조회
        List<UnitProgressDetailResponse> unitProgresses = unitProgressService.findAllUnitProgress(chapterId, userId);

        // 유닛 정보 + 유닛 진행도
        List<UnitDetail> unitPageResponses =  unitProgresses.stream()
                .map(unitProgress -> {
                    List<LessonProgressSummaryResponse> lessonProgressSummaries = lessonProgressService.getLessonProgressSummaries(unitProgress.unitId(), userId);

                    return UnitDetail.create(unitProgress, lessonProgressSummaries);
                })
                .toList();

        return UnitPageResponse.create(chapter, unitPageResponses);
    }

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemsInLesson(long lessonId){
        LearningAdditionalInfo learningAdditionalInfo = lessonService.getLearningAdditionalInfoByLessonId(lessonId);
        return LessonResponse.create(learningAdditionalInfo, problemService.getAllProblemInLesson(lessonId));
    }

    @Transactional
    public LearningResultSaveResponse saveLearningResult(
            long userId,
            LearningResultSaveRequest request
    ){
        LessonProgress lessonProgress = lessonProgressService.getLessonProgressAndUpdateStatus(request.lessonId(), userId, request.learningTime());

        LearningIds learningIds = lessonService.getLearningIdsByLessonId(request.lessonId());

        checkAndUpdateLearningProgress(learningIds.chapterId(), learningIds.unitId(), userId);

        LearningResultSaveResponse response;
        if(lessonProgress.getAttemptCount() == 1){ // 레슨 첫번째 풀이라면,

            response = saveLearningResultForFirstAttemptUser(userId, request);

            publisher.publishEvent(new UpdateLearningEvent(userId, learningIds.chapterId()));
            publisher.publishEvent(new LessonCompletedEvent(userId, 20, request.accuracy()));
            publisher.publishEvent(new LessonMissionEvent(userId, request.lessonId(), request.learningTime(), request.accuracy()));
            publisher.publishEvent(new QualifiedSolvedEvent(userId, request.learningTime(), request.accuracy()));
        }else{ // 레슨 첫번째 풀이가 아니라면,
            response = saveLearningResultForRetryUser(userId, request);

            publisher.publishEvent(new UpdateLearningEvent(userId, learningIds.chapterId()));
        }

        return response;
    }

    private void checkAndUpdateLearningProgress(long chapterId, long unitId, long userId){

        ChapterProgress chapterProgress = chapterProgressService.ensureChapterProgress(chapterId, userId);
        UnitProgress unitProgress = unitProgressService.ensureUnitProgress(unitId, userId);

        if(unitProgressService.updateUnitProgress(unitProgress)){
            chapterProgressService.updateChapterProgress(chapterProgress);
            log.info("=== 행성 클리어 업데이트 로직 실행 ===");
        }
    }

    private LearningResultSaveResponse saveLearningResultForFirstAttemptUser(long userId, LearningResultSaveRequest request){

        problemProgressService.saveProblemResults(userId, request.problemResults());

        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = userService.updateUserLevelAndXp(userId, 20, request.accuracy());

        return LearningResultSaveResponse.create(userLevelResponse, leagueName);
    }

    private LearningResultSaveResponse saveLearningResultForRetryUser(long userId, LearningResultSaveRequest request){

        String leagueName = userLeagueService.getUserLeagueName(userId);

        // TODO 불필요 로직
        UserLevelResponse userLevelResponse = userService.updateUserLevelAndXp(userId, 0, request.accuracy());

        return LearningResultSaveResponse.create(userLevelResponse, leagueName);
    }
}