package gravit.code.learning.facade;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.learning.dto.common.ConsecutiveSolvedDto;
import gravit.code.learning.dto.common.LearningIds;
import gravit.code.learning.dto.request.LearningSubmissionSaveRequest;
import gravit.code.learning.dto.response.LearningSubmissionSaveResponse;
import gravit.code.learning.service.LearningService;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.service.LessonService;
import gravit.code.lesson.service.LessonSubmissionService;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.service.ProblemSubmissionService;
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

@Log4j2
@Service
@RequiredArgsConstructor
public class LearningFacade {

    private final ApplicationEventPublisher publisher;
    private final UserService userService;
    private final UserLeagueService userLeagueService;
    private final UnitService unitService;
    private final LessonService lessonService;
    private final LessonSubmissionService lessonSubmissionService;
    private final ProblemSubmissionService problemSubmissionService;
    private final LearningService learningService;

    private static final int POINT_PER_LESSON = 20;

    @Transactional
    public LearningSubmissionSaveResponse saveLearningSubmission(
            long userId,
            LearningSubmissionSaveRequest request
    ){
        boolean isFirstTry = lessonSubmissionService.checkUserNotSubmitted(request.lessonSubmissionSaveRequest().lessonId(), userId);

        lessonSubmissionService.saveLessonSubmission(request.lessonSubmissionSaveRequest(), userId, isFirstTry);
        problemSubmissionService.saveProblemSubmissions(userId, request.problemSubmissionRequests(), isFirstTry);

        UnitSummary unitSummary = unitService.getUnitSummaryByLessonId(request.lessonSubmissionSaveRequest().lessonId());
        String leagueName = userLeagueService.getUserLeagueName(userId);
        UserLevelResponse userLevelResponse = updateUserLevelBySubmission(userId, request.lessonSubmissionSaveRequest(), isFirstTry);

        LearningIds learningIds = lessonService.getLearningIdsByLessonId(request.lessonSubmissionSaveRequest().lessonId());

        // Learning 업데이트 후 연속학습 처리
        ConsecutiveSolvedDto consecutiveSolvedDto = learningService.updateLearningStatus(userId, learningIds.chapterId());

        if(isFirstTry){
            publisher.publishEvent(new LessonCompletedEvent(
                    userId,
                    request.lessonSubmissionSaveRequest().lessonId(),
                    learningIds.chapterId(),
                    POINT_PER_LESSON,
                    request.lessonSubmissionSaveRequest().accuracy(),
                    request.lessonSubmissionSaveRequest().learningTime(),
                    consecutiveSolvedDto.before(),
                    consecutiveSolvedDto.after()
            ));
        }

        return LearningSubmissionSaveResponse.create(
                leagueName,
                userLevelResponse,
                unitSummary
        );
    }

    private UserLevelResponse updateUserLevelBySubmission(
            long userId,
            LessonSubmissionSaveRequest request,
            boolean isFirstTry
    ){

        UserLevelResponse userLevelResponse;

        if(isFirstTry){
            userLevelResponse = userService.updateUserLevelAndXp(userId, POINT_PER_LESSON, request.accuracy());
        }else{
            userLevelResponse = userService.updateUserLevelAndXp(userId, 0, request.accuracy());
        }
        return userLevelResponse;
    }

    @Transactional
    public void saveProblemSubmission(
            long userId,
            ProblemSubmissionRequest request
    ) {
        problemSubmissionService.saveProblemSubmission(userId, request);
    }
}