package gravit.code.learning.facade;

import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.chapter.service.ChapterService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.QualifiedSolvedEvent;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.dto.response.LearningSubmissionSaveResponse;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.lesson.dto.response.LessonSummary;
import gravit.code.lesson.service.LessonService;
import gravit.code.lesson.service.LessonSubmissionService;
import gravit.code.mission.dto.event.LessonMissionEvent;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.problem.service.ProblemService;
import gravit.code.problem.service.ProblemSubmissionService;
import gravit.code.unit.dto.response.UnitDetail;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.unit.service.UnitService;
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
                unitId,
                lessonSummaries
        );
    }

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemsInLesson(
            long lessonId,
            long userId
    ){
        UnitSummary unitSummary = unitService.getUnitSummaryByLessonId(lessonId);

        List<ProblemResponse> problems = problemService.getAllProblemInLesson(lessonId, userId);

        return LessonResponse.of(
                unitSummary,
                problems
        );
    }

    @Transactional(readOnly = true)
    public BookmarkedProblemResponse getBookmarkedProblemsInUnit(
            long userId,
            long unitId
    ) {
        UnitSummary unitSummary = unitService.getUnitSummaryByUnitId(unitId);

        List<ProblemResponse> problems = problemService.getBookmarkedProblemInUnit(unitId, userId);

        return BookmarkedProblemResponse.of(
                unitSummary,
                problems
        );
    }

    @Transactional(readOnly = true)
    public WrongAnsweredProblemsResponse getWrongAnsweredProblemsInUnit(
            long userId,
            long unitId
    ) {
        UnitSummary unitSummary = unitService.getUnitSummaryByUnitId(unitId);

        List<ProblemResponse> problems = problemService.getWrongAnsweredProblemsInUnit(unitId, userId);

        return WrongAnsweredProblemsResponse.of(
                unitSummary,
                problems
        );
    }

    @Transactional
    public LearningSubmissionSaveResponse saveLearningSubmission(
            long userId,
            LearningSubmissionSaveRequest request
    ){
        boolean isFirstTry = lessonSubmissionService.checkUserSubmitted(request.lessonSubmissionSaveRequest().lessonId(), userId);

        lessonSubmissionService.saveLessonSubmission(request.lessonSubmissionSaveRequest(), userId, isFirstTry);
        problemSubmissionService.saveProblemSubmissions(userId, request.problemSubmissionRequests(), isFirstTry);

        UnitSummary unitSummary = unitService.getUnitSummaryByLessonId(request.lessonSubmissionSaveRequest().lessonId());
        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = updateUserLevelBySubmission(userId, request.lessonSubmissionSaveRequest(), isFirstTry);

        LearningIds learningIds = lessonService.getLearningIdsByLessonId(request.lessonSubmissionSaveRequest().lessonId());

        publisher.publishEvent(new UpdateLearningEvent(userId, learningIds.chapterId()));

        if(isFirstTry){
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

    @Transactional
    public void saveProblemSubmission(
            long userId,
            ProblemSubmissionRequest request
    ) {
        problemSubmissionService.saveProblemSubmission(userId, request);
    }

    private UserLevelResponse updateUserLevelBySubmission(
            long userId,
            LessonSubmissionSaveRequest request,
            boolean isFirstTry
    ){

        UserLevelResponse userLevelResponse;

        if(isFirstTry){
            userLevelResponse = userService.updateUserLevelAndXp(userId, 20, request.accuracy());
        }else{
            userLevelResponse = userService.updateUserLevelAndXp(userId, 0, request.accuracy());
        }
        return userLevelResponse;
    }
}