package gravit.code.lesson.facade;

import gravit.code.bookmark.service.BookmarkService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.learning.dto.internal.ConsecutiveSolvedDto;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.service.LearningCommandService;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.dto.response.LessonDetailResponse;
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

import java.util.List;

@Facade
@RequiredArgsConstructor
public class LessonFacade {

    private static final int POINT_PER_LESSON = 20;

    private final LessonQueryService lessonQueryService;
    private final LessonSubmissionCommandService lessonSubmissionCommandService;
    private final LessonSubmissionQueryService lessonSubmissionQueryService;

    private final UnitQueryService unitQueryService;
    private final ProblemSubmissionCommandService problemSubmissionCommandService;
    private final WrongAnsweredNoteService wrongAnsweredNoteService;
    private final BookmarkService bookmarkService;

    private final LearningCommandService learningCommandService;

    private final UserService userService;
    private final UserLeagueService userLeagueService;

    private final ApplicationEventPublisher publisher;

    @Transactional(readOnly = true)
    public LessonDetailResponse getAllLessonInUnit(
            long userId,
            long unitId
    ) {
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByUnitId(unitId);

        List<LessonSummaryResponse> lessonSummaries = lessonQueryService.getAllLessonInUnit(userId, unitId);

        boolean bookmarkAccessible = bookmarkService.checkBookmarkedProblemExists(userId, unitId);
        boolean wrongAnsweredNoteAccessible = wrongAnsweredNoteService.checkWrongAnsweredProblemExists(userId, unitId);

        return LessonDetailResponse.create(
                unitSummaryResponse,
                bookmarkAccessible,
                wrongAnsweredNoteAccessible,
                unitId,
                lessonSummaries
        );
    }

    @Transactional
    public LessonSubmissionSaveResponse saveLessonSubmission(
            long userId,
            LearningSubmissionSaveRequest request
    ){
        // 레슨, 문제 풀이 추출
        LessonSubmissionSaveRequest lessonSubmissionSaveRequest = request.lessonSubmissionSaveRequest();
        List<ProblemSubmissionSaveRequest> problemSubmissionSaveRequests = request.problemSubmissionSaveRequests();

        // 챕터, 유닛, 레슨 아이디 추출
        LearningIdsDto learningIdsDto = lessonQueryService.getLearningIdsByLessonId(lessonSubmissionSaveRequest.lessonId());

        // 문제 풀이 정합성 검증
        problemSubmissionCommandService.validateProblemSubmissions(problemSubmissionSaveRequests);

        boolean isFirstTry = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonSubmissionSaveRequest.lessonId());

        // 레슨, 문제 풀이 저장
        lessonSubmissionCommandService.saveLessonSubmission(userId, lessonSubmissionSaveRequest);
        List<Long> wrongAnsweredProblemIds = problemSubmissionCommandService.saveProblemSubmissions(userId, problemSubmissionSaveRequests);

        // 틀린 문제에 대해 오답노트 저장
        wrongAnsweredProblemIds.forEach(problemId -> wrongAnsweredNoteService.saveWrongAnsweredNote(userId, problemId));

        // 응답 데이터 조회
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(lessonSubmissionSaveRequest.lessonId());
        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = userService.updateUserLevelByLessonSubmission(userId, lessonSubmissionSaveRequest, isFirstTry);

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

        return LessonSubmissionSaveResponse.create(
                leagueName,
                userLevelResponse,
                unitSummaryResponse
        );
    }
}
