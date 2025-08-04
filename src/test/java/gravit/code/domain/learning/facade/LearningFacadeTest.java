package gravit.code.domain.learning.facade;

import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import gravit.code.domain.chapterProgress.service.ChapterProgressService;
import gravit.code.domain.learning.dto.request.LearningResultSaveRequest;
import gravit.code.domain.learning.dto.request.RecentLearningEventDto;
import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import gravit.code.domain.lessonProgress.service.LessonProgressService;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problem.dto.request.ProblemResultRequest;
import gravit.code.domain.problem.dto.response.ProblemResponse;
import gravit.code.domain.problem.service.ProblemService;
import gravit.code.domain.problemProgress.service.ProblemProgressService;
import gravit.code.domain.unitProgress.dto.response.UnitPageResponse;
import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
import gravit.code.domain.unitProgress.service.UnitProgressService;
import gravit.code.domain.user.service.UserService;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LearningFacadeTest {

    @Mock
    private ApplicationEventPublisher publisher;

    @Mock
    private UserService userService;

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

    @Nested
    @DisplayName("모든 챕터(진행도 포함)를 조회할 때,")
    class GetAllChapters{

        private final List<ChapterProgressDetailResponse> chapterProgressDetailResponse = List.of(
                ChapterProgressDetailResponse.create(1L, "자료구조", "스택, 큐, 힙, 트리 등의 기본 자료구조를 학습합니다.", 8L, 6L),
                ChapterProgressDetailResponse.create(2L, "알고리즘", "정렬, 탐색, 동적계획법 등의 핵심 알고리즘을 학습합니다.", 10L, 4L),
                ChapterProgressDetailResponse.create(3L, "데이터베이스", "관계형 데이터베이스와 SQL 쿼리 최적화를 학습합니다.", 12L, 8L),
                ChapterProgressDetailResponse.create(4L, "네트워크", "TCP/IP, HTTP, 소켓 프로그래밍의 기초를 학습합니다.", 9L, 2L),
                ChapterProgressDetailResponse.create(5L, "운영체제", "프로세스, 스레드, 메모리 관리의 핵심 개념을 학습합니다.", 11L, 7L),
                ChapterProgressDetailResponse.create(6L, "컴퓨터 구조", "CPU, 메모리, 캐시 시스템의 동작 원리를 학습합니다.", 7L, 1L),
                ChapterProgressDetailResponse.create(7L, "소프트웨어 공학", "설계 패턴, 테스트 기법, 버전 관리를 학습합니다.", 6L, 6L),
                ChapterProgressDetailResponse.create(8L, "보안", "암호화, 인증, 웹 보안의 기본 원리를 학습합니다.", 5L, 0L)
        );

        @Test
        @DisplayName("진행도 조회에 실패하면 예외를 반환한다.") // 진행도 관련 값이 빈 리스트 = userId가 유효하지 않아 조회 실패
        void withInvalidUserId(){
            //given
            Long userId = 9999L;
            when(chapterProgressService.getChapterProgressDetails(userId)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));

            //when&then
            assertThatThrownBy(() -> learningFacade.getAllChapters(userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
        }

        @Test
        @DisplayName("진행도 조회에 성공하면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            Long userId = 1L;
            when(chapterProgressService.getChapterProgressDetails(userId)).thenReturn(chapterProgressDetailResponse);

            //when
            List<ChapterProgressDetailResponse> returnValue = learningFacade.getAllChapters(userId);

            //then
            assertThat(returnValue).isEqualTo(chapterProgressDetailResponse);
        }
    }

    @Nested
    @DisplayName("특정 챕터의 모든 유닛(진행도 포함)을 조회할 때,")
    class GetAllUnitsInChapter{

        private final List<UnitProgressDetailResponse> notEmptyProgresses = List.of(
                UnitProgressDetailResponse.create(1L, "스택", 4L, 4L),
                UnitProgressDetailResponse.create(2L, "큐", 5L, 3L),
                UnitProgressDetailResponse.create(3L, "연결 리스트", 6L, 1L),
                UnitProgressDetailResponse.create(5L, "해시", 4L, 2L)
        );

        @Test
        @DisplayName("진행도 조회에 실패하면 예외를 반환한다.") // 진행도 관련 값이 빈 리스트 = userId가 유효하지 않아 조회 실패
        void withInvalidUserId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            when(unitProgressService.findAllUnitProgress(chapterId, userId)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));

            //when&then
            assertThatThrownBy(() -> learningFacade.getAllUnitsInChapter(chapterId, userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
        }

        @Test
        @DisplayName("진행도 조회에 성공하면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            when(unitProgressService.findAllUnitProgress(chapterId, userId)).thenReturn(notEmptyProgresses);

            when(lessonProgressService.getLessonProgressSummaries(1L, userId))
                    .thenReturn(List.of(
                            LessonProgressSummaryResponse.create(1L, "스택 기본 개념", true),
                            LessonProgressSummaryResponse.create(2L, "스택 구현하기", true),
                            LessonProgressSummaryResponse.create(3L, "스택 활용 문제", true),
                            LessonProgressSummaryResponse.create(4L, "스택 심화 응용", true)
                    ));

            when(lessonProgressService.getLessonProgressSummaries(2L, userId))
                    .thenReturn(List.of(
                            LessonProgressSummaryResponse.create(5L, "큐 기본 개념", true),
                            LessonProgressSummaryResponse.create(6L, "선형 큐 구현", true),
                            LessonProgressSummaryResponse.create(7L, "원형 큐 구현", true),
                            LessonProgressSummaryResponse.create(8L, "우선순위 큐", false),
                            LessonProgressSummaryResponse.create(9L, "큐 활용 문제", false)
                    ));

            when(lessonProgressService.getLessonProgressSummaries(3L, userId))
                    .thenReturn(List.of(
                            LessonProgressSummaryResponse.create(10L, "연결 리스트 기본", true),
                            LessonProgressSummaryResponse.create(11L, "단일 연결 리스트", false),
                            LessonProgressSummaryResponse.create(12L, "이중 연결 리스트", false)
                    ));

            when(lessonProgressService.getLessonProgressSummaries(5L, userId))
                    .thenReturn(List.of(
                            LessonProgressSummaryResponse.create(23L, "해시 테이블 개념", true),
                            LessonProgressSummaryResponse.create(24L, "해시 함수", true),
                            LessonProgressSummaryResponse.create(25L, "충돌 해결 방법", false),
                            LessonProgressSummaryResponse.create(26L, "해시 응용", false)
                    ));
            //when
            List<UnitPageResponse> unitPageResponses = learningFacade.getAllUnitsInChapter(userId, chapterId);

            // then
            assertThat(unitPageResponses).hasSize(4);
            verify(lessonProgressService, times(4)).getLessonProgressSummaries(anyLong(), anyLong());
        }
    }

    @Nested
    @DisplayName("특정 레슨의 모든 문제를 조회할 때,")
    class GetAllProblemInLesson{

        private final List<ProblemResponse> problemResponses = List.of(
                ProblemResponse.create(1L, ProblemType.FILL_BLANK, "스택에서 마지막에 삽입된 데이터가 가장 먼저 삭제되는 원리를 ( )라고 합니다.", "-", "LIFO"),
                ProblemResponse.create(2L, ProblemType.SELECT_DESCRIPTION, "스택의 주요 연산이 아닌 것은?", "1. push, 2. pop, 3. peek, 4. enqueue", "4"),
                ProblemResponse.create(3L, ProblemType.FILL_BLANK, "큐에서 데이터가 삽입되는 곳을 ( ), 삭제되는 곳을 ( )라고 합니다.", "-", "rear, front"),
                ProblemResponse.create(4L, ProblemType.SELECT_DESCRIPTION, "다음 중 큐의 특성을 가장 잘 설명한 것은?", "1. LIFO 구조, 2. FIFO 구조, 3. 랜덤 접근, 4. 양방향 접근", "2"),
                ProblemResponse.create(5L, ProblemType.FILL_BLANK, "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.", "-", "오름차순 정렬"),
                ProblemResponse.create(6L, ProblemType.SELECT_DESCRIPTION, "트리에서 루트 노드의 높이는?", "1. 0, 2. 1, 3. 트리의 깊이, 4. 노드 개수", "1"),
                ProblemResponse.create(7L, ProblemType.FILL_BLANK, "해시 테이블에서 서로 다른 키가 동일한 해시 값을 가지는 현상을 ( )라고 합니다.", "-", "충돌"),
                ProblemResponse.create(8L, ProblemType.SELECT_DESCRIPTION, "해시 충돌을 해결하는 방법이 아닌 것은?", "1. 체이닝, 2. 개방 주소법, 3. 이중 해싱, 4. 순차 탐색", "4"),
                ProblemResponse.create(9L, ProblemType.FILL_BLANK, "연결 리스트에서 각 노드는 데이터와 다음 노드를 가리키는 ( )로 구성됩니다.", "-", "포인터"),
                ProblemResponse.create(10L, ProblemType.SELECT_DESCRIPTION, "다음 중 시간 복잡도가 O(log n)인 연산은?", "1. 배열에서 순차 탐색, 2. 연결 리스트 삽입, 3. 이진 탐색 트리 탐색, 4. 해시 테이블 충돌시 탐색", "3")
        );

        @Test
        @DisplayName("빈 리스트가 조회되면 예외를 반환한다.")
        void withInvalidLessonId(){
            //given
            Long lessonId = 1L;

            when(problemService.getAllProblem(lessonId)).thenThrow(new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

            //when&then
            assertThatThrownBy(() -> learningFacade.getAllProblemsInLesson(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.PROBLEM_NOT_FOUND);
        }

        @Test
        @DisplayName("문제 리스트가 조회되면 정상적으로 반환한다.")
        void withValidLessonId(){
            //given
            Long lessonId = 1L;

            when(problemService.getAllProblem(lessonId)).thenReturn(problemResponses);

            //when
            List<ProblemResponse> returnValue = learningFacade.getAllProblemsInLesson(lessonId);

            //then
            assertThat(returnValue).isEqualTo(problemResponses);
            verify(problemService, times(1)).getAllProblem(lessonId);
        }
    }

    @Nested
    @DisplayName("문제 풀이 결과를 저장할 때,")
    class SaveLearningResult{

        private final Long userId = 1L;
        private final LearningResultSaveRequest validRequest = new LearningResultSaveRequest(
                1L,
                2L,
                3L,
                List.of(
                        new ProblemResultRequest(1L, true, 0L),
                        new ProblemResultRequest(2L, false, 2L),
                        new ProblemResultRequest(3L, true, 0L),
                        new ProblemResultRequest(4L, true, 0L),
                        new ProblemResultRequest(5L, false, 1L)
                )
        );

        @Nested
        @DisplayName("특정 학습 조회에 실패하면 예외를 반환한다.")
        class FailedAtFind{

            @Test
            @DisplayName("유닛 조회에 실패한 경우")
            void returnUnit404Exception(){
                //given
                doNothing().when(problemProgressService).saveProblemResults(userId, validRequest.problemResults());
                doNothing().when(lessonProgressService).updateLessonProgressStatus(validRequest.lessonId(), userId);

                when(unitProgressService.updateUnitProgress(validRequest.unitId(), userId)).thenThrow(new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));

                //when&then
                assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, validRequest))
                        .isInstanceOf(RestApiException.class)
                        .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.UNIT_NOT_FOUND);
            }

            @Test
            @DisplayName("유닛 조회는 통과, 챕터 조회는 실패한 경우")
            void returnChapter404Exception(){
                //given
                doNothing().when(problemProgressService).saveProblemResults(userId, validRequest.problemResults());
                doNothing().when(lessonProgressService).updateLessonProgressStatus(validRequest.lessonId(), userId);

                when(unitProgressService.updateUnitProgress(validRequest.unitId(), userId)).thenReturn(true);
                doThrow(new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND)).when(chapterProgressService).updateChapterProgress(validRequest.chapterId(), userId);

                //when&then
                assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, validRequest))
                        .isInstanceOf(RestApiException.class)
                        .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);

            }

        }

        @Nested
        @DisplayName("updateUnitProgress가")
        class UnitProgressServiceReturn{

            @Test
            @DisplayName("true를 반환하면 updateChapterProgress를 호출한다.")
            void invokeUpdateChapterProgress(){
                //given
                doNothing().when(problemProgressService).saveProblemResults(userId, validRequest.problemResults());
                doNothing().when(lessonProgressService).updateLessonProgressStatus(validRequest.lessonId(), userId);

                when(unitProgressService.updateUnitProgress(validRequest.unitId(), userId)).thenReturn(true);

                //when
                learningFacade.saveLearningResult(userId, validRequest);

                //then
                verify(chapterProgressService, times(1)).updateChapterProgress(validRequest.chapterId(), userId);
                verify(publisher, times(1)).publishEvent(new RecentLearningEventDto(userId, validRequest.chapterId()));
                verify(userService, times(1)).updateUserLevelAndXp(userId);
            }

            @Test
            @DisplayName("false를 반환하면 updateChapterProgress를 호출하지 않는다.")
            void notInvokeUpdateChapterProgress(){
                //given
                doNothing().when(problemProgressService).saveProblemResults(userId, validRequest.problemResults());
                doNothing().when(lessonProgressService).updateLessonProgressStatus(validRequest.lessonId(), userId);

                when(unitProgressService.updateUnitProgress(validRequest.unitId(), userId)).thenReturn(false);

                //when
                learningFacade.saveLearningResult(userId, validRequest);

                //then
                verify(chapterProgressService, never()).updateChapterProgress(validRequest.chapterId(), userId);
                verify(publisher, times(1)).publishEvent(new RecentLearningEventDto(userId, validRequest.chapterId()));
                verify(userService, times(1)).updateUserLevelAndXp(userId);
            }
        }
    }
}