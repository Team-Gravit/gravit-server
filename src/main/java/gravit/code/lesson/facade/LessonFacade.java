package gravit.code.lesson.facade;

import gravit.code.bookmark.service.BookmarkService;
import gravit.code.chapter.dto.response.ChapterBriefResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.learning.dto.internal.ConsecutiveSolvedDto;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.service.LearningCommandService;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResultResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
import gravit.code.lesson.dto.response.LessonSummaryResponse;
import gravit.code.lesson.service.LessonQueryService;
import gravit.code.lesson.service.LessonSubmissionCommandService;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.service.ProblemSubmissionCommandService;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeagueService;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class LessonFacade {

    private static final int POINT_PER_LESSON = 20;

    private final LessonQueryService lessonQueryService;
    private final LessonSubmissionCommandService lessonSubmissionCommandService;
    private final LessonSubmissionQueryService lessonSubmissionQueryService;

    private final ChapterQueryService chapterQueryService;
    private final UnitQueryService unitQueryService;
    private final ProblemSubmissionCommandService problemSubmissionCommandService;
    private final WrongAnsweredNoteService wrongAnsweredNoteService;
    private final BookmarkService bookmarkService;

    private final LearningCommandService learningCommandService;

    private final UserService userService;
    private final UserLeagueService userLeagueService;

    private final ApplicationEventPublisher publisher;
    private final TransactionTemplate transactionTemplate;

    @Transactional(readOnly = true)
    public LessonDetailResponse getAllLessonInUnit(
            long userId,
            long unitId
    ) {
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByUnitId(unitId);

        ChapterBriefResponse chapterSummary = chapterQueryService.getChapterBriefByUnitId(unitId);

        List<LessonSummaryResponse> lessonSummaries = lessonQueryService.getAllLessonInUnit(userId, unitId);

        boolean bookmarkAccessible = bookmarkService.checkBookmarkedProblemExists(userId, unitId);
        boolean wrongAnsweredNoteAccessible = wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unitId);

        return LessonDetailResponse.create(
                chapterSummary,
                unitSummaryResponse,
                bookmarkAccessible,
                wrongAnsweredNoteAccessible,
                unitId,
                lessonSummaries
        );
    }

    public LessonSubmissionSaveResponse saveLessonSubmission(
            long userId,
            LearningSubmissionSaveRequest request
    ){
        LessonSubmissionSaveRequest lessonSubmissionSaveRequest = request.lessonSubmissionSaveRequest();
        List<ProblemSubmissionSaveRequest> problemSubmissionSaveRequests = request.problemSubmissionSaveRequests();

        LearningIdsDto learningIdsDto = lessonQueryService.getLearningIdsByLessonId(lessonSubmissionSaveRequest.lessonId());
        problemSubmissionCommandService.validateProblemSubmissions(problemSubmissionSaveRequests);
        boolean isFirstTry = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonSubmissionSaveRequest.lessonId());

        Long lessonSubmissionId = transactionTemplate.execute(status -> {
            long submissionId = lessonSubmissionCommandService.saveLessonSubmission(userId, lessonSubmissionSaveRequest);

            List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, problemSubmissionSaveRequests);
            wrongAnsweredNoteService.saveWrongAnsweredNotes(userId, wrongAnsweredProblemIds);

            userService.updateUserLevelByLessonSubmission(userId, lessonSubmissionSaveRequest, isFirstTry);
            ConsecutiveSolvedDto consecutiveSolvedDto = learningCommandService.updateLearningStatus(userId, learningIdsDto.chapterId());

            if(isFirstTry){
                publisher.publishEvent(new LessonCompletedEvent(
                        userId,
                        learningIdsDto.lessonId(),
                        learningIdsDto.chapterId(),
                        POINT_PER_LESSON,
                        lessonSubmissionSaveRequest.accuracy(),
                        lessonSubmissionSaveRequest.learningTime(),
                        consecutiveSolvedDto.before(),
                        consecutiveSolvedDto.after()
                ));
            }

            return submissionId;
        });

        return LessonSubmissionSaveResponse.create(lessonSubmissionId);
    }

    @Transactional(readOnly = true)
    public LessonResultResponse getLessonResult(
            long userId,
            long lessonSubmissionId
    ){
        long lessonId = lessonSubmissionQueryService.getSubmittedLessonId(userId, lessonSubmissionId);

        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = userService.getUserLevel(userId);
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(lessonId);

        return LessonResultResponse.create(
                leagueName,
                userLevelResponse,
                unitSummaryResponse
        );
    }
}
