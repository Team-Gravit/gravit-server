package gravit.code.learning.facade;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.QualifiedSolvedEvent;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.dto.request.LessonSubmissionSaveRequest;
import gravit.code.learning.dto.response.*;
import gravit.code.learning.service.*;
import gravit.code.mission.dto.event.LessonMissionEvent;
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
    private final UserLeagueService userLeagueService;

    private final ChapterService chapterService;
    private final UnitService unitService;
    private final LessonService lessonService;
    private final ProblemService problemService;

    private final LessonSubmissionService lessonSubmissionService;
    private final ProblemSubmissionService problemSubmissionService;

    @Transactional(readOnly = true)
    public List<ChapterDetailResponse> getAllChapterDetail(long userId){
        List<ChapterSummary> chapterSummaries = chapterService.getAllChapterSummary();

        return chapterSummaries.stream()
                .map(chapterSummary -> {
                    long chapterId = chapterSummary.chapterId();

                    double chapterProgressRate = lessonService.getProgressRateByChapterId(chapterId, userId);

                    return ChapterDetailResponse.create(
                            chapterSummary,
                            chapterProgressRate
                    );
                }).toList();
    }

    @Transactional(readOnly = true)
    public UnitDetailResponse getAllUnitDetailInChapter(
            long userId,
            long chapterId
    ){
        ChapterSummary chapterSummary = chapterService.getChapterSummaryByChapterId(chapterId);

        List<UnitSummary> unitSummaries = unitService.getAllUnitSummaryByChapterId(chapterId);

        List<UnitDetail> unitDetails = unitSummaries.stream()
                .map(unitSummary -> {
                    long unitId = unitSummary.unitId();

                    double unitProgressRate = lessonService.getProgressRateByUnitId(unitId, userId);

                    return UnitDetail.create(
                            unitSummary,
                            unitProgressRate
                    );
                }).toList();

        return UnitDetailResponse.create(
                chapterSummary,
                unitDetails
        );
    }

    @Transactional(readOnly = true)
    public LessonDetailResponse getAllLessonInUnit(
            long userId,
            long unitId
    ) {
        ChapterSummary chapterSummary = chapterService.getChapterSummaryByUnitId(unitId);

        List<LessonSummary> lessonSummaries = lessonService.getAllLessonSummaryByUnitId(unitId, userId);

        return LessonDetailResponse.create(
                chapterSummary,
                lessonSummaries
        );
    }

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemsInLesson(long lessonId){
        UnitSummary unitSummary = unitService.getUnitSummaryLessonId(lessonId);

        List<ProblemResponse> problemResponses = problemService.getAllProblemInLesson(lessonId);

        return LessonResponse.create(
                unitSummary,
                problemResponses
        );
    }

    @Transactional
    public LearningSubmissionSaveResponse saveLearningSubmission(
            long userId,
            LearningSubmissionSaveRequest request
    ){
        boolean isFirstTry = lessonSubmissionService.checkUserSubmitted(request.lessonSubmissionSaveRequest().lessonId(), userId);

        lessonSubmissionService.saveLessonSubmission(request.lessonSubmissionSaveRequest(), userId, isFirstTry);
        problemSubmissionService.saveProblemSubmission(userId, request.problemSubmissionRequests(), isFirstTry);

        UnitSummary unitSummary = unitService.getUnitSummaryLessonId(request.lessonSubmissionSaveRequest().lessonId());
        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = updateUserLevelBySubmission(userId, request.lessonSubmissionSaveRequest(), isFirstTry);

        LearningIds learningIds = lessonService.getLearningIdsByLessonId(request.lessonSubmissionSaveRequest().lessonId());

        publisher.publishEvent(new UpdateLearningEvent(userId, learningIds.chapterId()));

        if(isFirstTry){
            /**
             * 아래 두 이벤트 발행이 로직적으로 중복되는 것은 아니지만 발행하는 이벤트의 이름을 봤을 때, 어 왜 두번 반복되지? 싶을 것 같아서 적절하게 수정이 필요해보임.
             */
            publisher.publishEvent(new LessonCompletedEvent(userId, 20, request.lessonSubmissionSaveRequest().accuracy()));
            publisher.publishEvent(new LessonMissionEvent(userId, request.lessonSubmissionSaveRequest().lessonId(), request.lessonSubmissionSaveRequest().learningTime(), request.lessonSubmissionSaveRequest().accuracy()));
            publisher.publishEvent(new QualifiedSolvedEvent(userId, request.lessonSubmissionSaveRequest().learningTime(), request.lessonSubmissionSaveRequest().accuracy()));
        }

        return LearningSubmissionSaveResponse.create(
                leagueName,
                userLevelResponse,
                unitSummary
        );
    }

    private UserLevelResponse updateUserLevelBySubmission(long userId, LessonSubmissionSaveRequest request, boolean isFirstTry){

        UserLevelResponse userLevelResponse;

        if(isFirstTry){
            userLevelResponse = userService.updateUserLevelAndXp(userId, 20, request.accuracy());
        }else{
            userLevelResponse = userService.updateUserLevelAndXp(userId, 0, request.accuracy());
        }
        return userLevelResponse;
    }
}