package gravit.code.domain.learning.facade;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.learning.dto.request.LearningResultSaveRequest;
import gravit.code.domain.learning.service.LearningService;
import gravit.code.domain.lessonProgress.dto.response.LessonInfo;
import gravit.code.domain.lessonProgress.service.LessonProgressService;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problem.dto.request.ProblemResult;
import gravit.code.domain.problem.dto.response.ProblemInfo;
import gravit.code.domain.problem.service.ProblemService;
import gravit.code.domain.problemProgress.service.ProblemProgressService;
import gravit.code.domain.unitProgress.dto.response.UnitInfo;
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
    private LearningService learningService;

    @Mock
    private ProblemService problemService;

    @Mock
    private ChapterProgressService chapterProgressService;

    @Mock
    private UnitProgressService unitProgressService;

    @Mock
    private LessonProgressService lessonProgressService;

    @Mock
    private ProblemProgressService problemProgressService;

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
        learningFacade.saveLearningResult(userId, request);

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
        learningFacade.saveLearningResult(userId, request);

        //then
        verify(problemProgressService).saveProblemResults(userId, request.problemResults());
        verify(unitProgressService).updateUnitProgress(userId, request.unitId());
        verify(chapterProgressService, never()).updateChapterProgress(userId, chapterId);
        verify(userService).updateUserLevel(userId);
    }

    @Test
    @DisplayName("lessonId를 통해 레슨에 속한 문제를 조회할 수 있다.")
    void getAllProblemsByLessonId(){
        //given
        Long lessonId = 1L;

        ProblemInfo problemInfo1 = ProblemInfo.create(
            1L, ProblemType.FILL_BLANK, "질문1", "-", "정답1"
        );
        ProblemInfo problemInfo2 = ProblemInfo.create(
            1L, ProblemType.SELECT_DESCRIPTION, "질문2", "택지2", "정답2"
        );
        ProblemInfo problemInfo3 = ProblemInfo.create(
            1L, ProblemType.FILL_BLANK, "질문3", "-", "정답3"
        );
        ProblemInfo problemInfo4 = ProblemInfo.create(
            1L, ProblemType.SELECT_DESCRIPTION, "질문4", "택지4", "정답4"
        );

        List<ProblemInfo> problemInfos = List.of(
                problemInfo1, problemInfo2, problemInfo3, problemInfo4
        );

        when(problemService.getAllProblems(lessonId)).thenReturn(problemInfos);

        //when
        learningFacade.getAllProblemsInLesson(lessonId);

        //then
        verify(problemService).getAllProblems(lessonId);
    }

    @Test
    @DisplayName("userId를 통해 유저의 학습 진행도가 포함된 Chapter들을 조회할 수 있다.")
    void getAllChaptersWithLearningProgressByUserId(){
        //given
        Long userId = 1L;

        ChapterInfoResponse chapterInfoResponse1 = ChapterInfoResponse.create(
                1L, "자료구조", "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다.", 10L, 3L
        );

        ChapterInfoResponse chapterInfoResponse2 = ChapterInfoResponse.create(
                2L, "알고리즘", "정렬, 탐색, 동적계획법 등 다양한 알고리즘을 학습합니다.", 8L, 5L
        );

        ChapterInfoResponse chapterInfoResponse3 = ChapterInfoResponse.create(
                3L, "데이터베이스", "관계형 데이터베이스와 SQL을 중심으로 학습합니다.", 12L, 2L
        );

        ChapterInfoResponse chapterInfoResponse4 = ChapterInfoResponse.create(
                4L, "네트워크", "OSI 7계층과 TCP/IP 프로토콜에 대해 학습합니다.", 15L, 0L
        );

        List<ChapterInfoResponse>  chapterInfoResponses = List.of(
                chapterInfoResponse1, chapterInfoResponse2, chapterInfoResponse3, chapterInfoResponse4
        );

        when(chapterProgressService.getAllChaptersWithProgress(userId)).thenReturn(chapterInfoResponses);

        //when
        learningFacade.getAllChapters(userId);

        //then
        verify(chapterProgressService).getAllChaptersWithProgress(userId);
    }

    @Test
    @DisplayName("userId와 chapterId를 통해 유닛별 진행도가 포함된 Unit들을 조회할 수 있다. ")
    void getAllUnitsWithLearningProgressByUserId(){
        //given
        Long userId = 1L;
        Long chapterId = 1L;

        List<UnitInfo> unitInfos = List.of(
                UnitInfo.create(1L, "스택", 3L, 2L),
                UnitInfo.create(2L, "큐", 4L, 1L),
                UnitInfo.create(3L, "힙", 5L, 0L)
        );

        List<LessonInfo> unit1Lessons = List.of(
                LessonInfo.create(1L, "스택 기초", true),
                LessonInfo.create(2L, "스택 응용", true),
                LessonInfo.create(3L, "스택 문제풀이", false)
        );

        List<LessonInfo> unit2Lessons = List.of(
                LessonInfo.create(4L, "큐 기초", true),
                LessonInfo.create(5L, "큐 응용", false),
                LessonInfo.create(6L, "큐 문제풀이", false),
                LessonInfo.create(7L, "우선순위 큐", false)
        );

        List<LessonInfo> unit3Lessons = List.of(
                LessonInfo.create(8L, "힙 개념", false),
                LessonInfo.create(9L, "힙 구현", false),
                LessonInfo.create(10L, "힙 정렬", false),
                LessonInfo.create(11L, "힙 응용", false),
                LessonInfo.create(12L, "힙 문제풀이", false)
        );

        when(unitProgressService.getAllUnitsWithProgress(userId, chapterId)).thenReturn(unitInfos);

        when(lessonProgressService.getAllLessonsWithProgress(userId, unitInfos.get(0).unitId())).thenReturn(unit1Lessons);
        when(lessonProgressService.getAllLessonsWithProgress(userId, unitInfos.get(1).unitId())).thenReturn(unit2Lessons);
        when(lessonProgressService.getAllLessonsWithProgress(userId, unitInfos.get(2).unitId())).thenReturn(unit3Lessons);

        //when
        learningFacade.getAllUnitsInChapter(userId, chapterId);

        //then
        verify(unitProgressService).getAllUnitsWithProgress(userId, chapterId);
        verify(lessonProgressService, times(1)).getAllLessonsWithProgress(userId, unitInfos.get(0).unitId());
        verify(lessonProgressService, times(1)).getAllLessonsWithProgress(userId, unitInfos.get(1).unitId());
        verify(lessonProgressService, times(1)).getAllLessonsWithProgress(userId, unitInfos.get(2).unitId());

    }
}