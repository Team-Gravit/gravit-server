package gravit.code.learning.facade;

import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.learning.dto.request.LearningResultSaveRequest;
import gravit.code.domain.learning.facade.LearningFacade;
import gravit.code.domain.problem.dto.request.ProblemResult;
import gravit.code.domain.problemProgress.service.ProblemProgressService;
import gravit.code.domain.unitProgress.service.UnitProgressService;
import gravit.code.domain.user.dto.response.UserLevelResponse;
import gravit.code.domain.user.service.UserService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LearningFacadeTest {

    @Mock
    private UserService userService;

    @Mock
    private ProblemProgressService problemProgressService;

    @Mock
    private UnitProgressService unitProgressService;

    @Mock
    private ChapterProgressService chapterProgressService;

    @InjectMocks
    private LearningFacade learningFacade;

    @Test
    @DisplayName("학습 결과 저장 후, Unit이 완료되면 ChapterProgress의 completedUnits가 1만큼 증가하며, 유저의 레벨 정보를 반환한다.")
    void saveLearningProgressAndUpdateChapterProgressIfUnitCompletedAndReturnUserLevelInfo(){
        //given
        Long userId = 1L;
        Long lessonId = 1L;
        Long unitId = 1L;
        Long chapterId = 1L;
        List<ProblemResult> problemResults = List.of(
                new ProblemResult(1L, true, 0L),
                new ProblemResult(2L, true, 0L),
                new ProblemResult(3L, true, 0L),
                new ProblemResult(4L, false, 1L),
                new ProblemResult(5L, true, 0L),
                new ProblemResult(6L, true, 0L),
                new ProblemResult(7L, true, 0L),
                new ProblemResult(8L, true, 0L),
                new ProblemResult(9L, true, 0L),
                new ProblemResult(10L, true, 0L)
                );
        LearningResultSaveRequest request = new LearningResultSaveRequest(chapterId, unitId, lessonId, problemResults);
        UserLevelResponse expectedUserLevelResponse = UserLevelResponse.create(1, 20);


        when(unitProgressService.updateUnitProgress(userId, request.unitId())).thenReturn(true);
        when(userService.updateUserLevel(userId)).thenReturn(expectedUserLevelResponse);

        // when
        learningFacade.saveLearningProgress(userId, request);

        //then
        verify(problemProgressService).saveProblemResults(userId, request.problemResults());
        verify(unitProgressService).updateUnitProgress(userId, request.unitId());
        verify(chapterProgressService).updateChapterProgress(userId, chapterId);
        verify(userService).updateUserLevel(userId);

    }

    @Test
    @DisplayName("학습 결과 저장 후, Unit이 완료되지 않으면 ChapterProgress의 업데이트 로직은 호출되지 않으며, 유저의 레벨 정보를 반환한다.")
    void saveLearningProgressAndNotUpdateChapterProgressIfUnitNotCompletedAndReturnUserLevelInfo(){
        //given
        Long userId = 1L;
        Long lessonId = 1L;
        Long unitId = 1L;
        Long chapterId = 1L;
        List<ProblemResult> problemResults = List.of(
                new ProblemResult(1L, true, 0L),
                new ProblemResult(2L, true, 0L),
                new ProblemResult(3L, true, 0L),
                new ProblemResult(4L, false, 1L),
                new ProblemResult(5L, true, 0L),
                new ProblemResult(6L, true, 0L),
                new ProblemResult(7L, true, 0L),
                new ProblemResult(8L, true, 0L),
                new ProblemResult(9L, true, 0L),
                new ProblemResult(10L, true, 0L)
        );
        LearningResultSaveRequest request = new LearningResultSaveRequest(chapterId, unitId, lessonId, problemResults);
        UserLevelResponse expectedUserLevelResponse = UserLevelResponse.create(1, 20);


        when(unitProgressService.updateUnitProgress(userId, request.unitId())).thenReturn(false);
        when(userService.updateUserLevel(userId)).thenReturn(expectedUserLevelResponse);

        // when
        learningFacade.saveLearningProgress(userId, request);

        //then
        verify(problemProgressService).saveProblemResults(userId, request.problemResults());
        verify(unitProgressService).updateUnitProgress(userId, request.unitId());
        verify(chapterProgressService, never()).updateChapterProgress(userId, chapterId);
        verify(userService).updateUserLevel(userId);
    }
}