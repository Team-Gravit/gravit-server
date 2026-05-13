package gravit.code.lesson.facade;

import gravit.code.bookmark.service.BookmarkService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.learning.dto.internal.ConsecutiveSolvedDto;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.service.LearningService;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonSubmissionSaveResponse;
import gravit.code.lesson.dto.response.LessonSummaryResponse;
import gravit.code.lesson.service.LessonQueryService;
import gravit.code.lesson.service.LessonSubmissionCommandService;
import gravit.code.lesson.service.LessonSubmissionQueryService;
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

    private final LearningService learningService;

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
        // 첫번째 풀이인지 체크
        boolean isFirstTry = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, request.lessonSubmissionSaveRequest().lessonId());

        // 레슨 풀이 결과, 문제 풀이 결과 저장
        lessonSubmissionCommandService.saveLessonSubmission(userId, request.lessonSubmissionSaveRequest(), isFirstTry);
        problemSubmissionCommandService.saveProblemSubmissions(userId, request.problemSubmissionRequests(), isFirstTry);

        // 응답 데이터 조회
        UnitSummaryResponse unitSummaryResponse = unitQueryService.getUnitSummaryByLessonId(request.lessonSubmissionSaveRequest().lessonId());
        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = userService.updateUserLevelByLessonSubmission(userId, request.lessonSubmissionSaveRequest(), isFirstTry);

        LearningIdsDto learningIdsDto = lessonQueryService.getLearningIdsByLessonId(request.lessonSubmissionSaveRequest().lessonId());

        ConsecutiveSolvedDto consecutiveSolvedDto = learningService.updateLearningStatus(userId, learningIdsDto.chapterId());
        if(isFirstTry){
            publisher.publishEvent(new LessonCompletedEvent(
                    userId,
                    learningIdsDto.lessonId(),
                    learningIdsDto.chapterId(),
                    POINT_PER_LESSON,
                    request.lessonSubmissionSaveRequest().accuracy(),
                    request.lessonSubmissionSaveRequest().learningTime(),
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
