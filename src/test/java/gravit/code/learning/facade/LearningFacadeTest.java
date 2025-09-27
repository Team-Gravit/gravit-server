package gravit.code.learning.facade;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.QualifiedSolvedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import gravit.code.learning.dto.LearningAdditionalInfo;
import gravit.code.learning.dto.LearningIds;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.request.ProblemResultRequest;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.dto.response.OptionResponse;
import gravit.code.learning.dto.response.ProblemResponse;
import gravit.code.learning.service.LessonService;
import gravit.code.learning.service.ProblemService;
import gravit.code.mission.dto.event.LessonMissionEvent;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.UnitProgress;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import gravit.code.progress.dto.response.UnitPageResponse;
import gravit.code.progress.dto.response.UnitProgressDetailResponse;
import gravit.code.progress.service.ChapterProgressService;
import gravit.code.progress.service.LessonProgressService;
import gravit.code.progress.service.ProblemProgressService;
import gravit.code.progress.service.UnitProgressService;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeagueService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.test.util.ReflectionTestUtils;

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
    private LessonService lessonService;

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

    @Mock
    private UserLeagueService userLeagueService;

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

        private final List<ProblemResponse> problemResponses;

        {
            Problem problem1 = Problem.create(ProblemType.OBJECTIVE, "스택의 기본 동작 원리는?", "스택 자료구조에 대한 문제입니다.", "1", 1L);
            ReflectionTestUtils.setField(problem1, "id", 1L);

            Problem problem2 = Problem.create(ProblemType.OBJECTIVE, "큐의 특징으로 올바른 것은?", "큐 자료구조에 대한 문제입니다.", "2", 1L);
            ReflectionTestUtils.setField(problem2, "id", 2L);

            Problem problem3 = Problem.create(ProblemType.OBJECTIVE, "연결 리스트의 장점은?", "연결 리스트에 대한 문제입니다.", "3", 1L);
            ReflectionTestUtils.setField(problem3, "id", 3L);

            Problem problem4 = Problem.create(ProblemType.OBJECTIVE, "배열의 시간 복잡도는?", "배열 접근에 대한 문제입니다.", "1", 1L);
            ReflectionTestUtils.setField(problem4, "id", 4L);

            Problem problem5 = Problem.create(ProblemType.SUBJECTIVE, "스택을 구현하는 방법을 설명하시오.", "스택 구현에 대한 문제입니다.", "배열이나 연결리스트로 구현 가능", 1L);
            ReflectionTestUtils.setField(problem5, "id", 5L);

            Problem problem6 = Problem.create(ProblemType.SUBJECTIVE, "큐와 스택의 차이점을 설명하시오.", "자료구조 비교 문제입니다.", "큐는 FIFO, 스택은 LIFO", 1L);
            ReflectionTestUtils.setField(problem6, "id", 6L);

            problemResponses = List.of(
                    ProblemResponse.create(problem1, List.of(
                            OptionResponse.create(1L, 1L, "LIFO (Last In First Out)", "스택은 마지막에 들어간 데이터가 먼저 나오는 구조입니다.", true),
                            OptionResponse.create(2L, 1L, "FIFO (First In First Out)", "이는 큐의 특징입니다.", false),
                            OptionResponse.create(3L, 1L, "랜덤 접근 가능", "스택은 순차 접근만 가능합니다.", false),
                            OptionResponse.create(4L, 1L, "정렬된 데이터 저장", "스택은 정렬과 무관합니다.", false)
                    )),
                    ProblemResponse.create(problem2, List.of(
                            OptionResponse.create(5L, 2L, "FIFO (First In First Out)", "큐는 먼저 들어간 데이터가 먼저 나오는 구조입니다.", true),
                            OptionResponse.create(6L, 2L, "LIFO (Last In First Out)", "이는 스택의 특징입니다.", false),
                            OptionResponse.create(7L, 2L, "이진 탐색 가능", "큐는 탐색 자료구조가 아닙니다.", false),
                            OptionResponse.create(8L, 2L, "인덱스 접근 가능", "큐는 양 끝에서만 접근 가능합니다.", false)
                    )),
                    ProblemResponse.create(problem3, List.of(
                            OptionResponse.create(9L, 3L, "동적 크기 조절", "연결 리스트는 실행 시간에 크기를 조절할 수 있습니다.", true),
                            OptionResponse.create(10L, 3L, "빠른 랜덤 접근", "배열의 장점입니다.", false),
                            OptionResponse.create(11L, 3L, "메모리 연속성", "배열의 장점입니다.", false),
                            OptionResponse.create(12L, 3L, "캐시 효율성", "배열의 장점입니다.", false)
                    )),
                    ProblemResponse.create(problem4, List.of(
                            OptionResponse.create(13L, 4L, "O(1)", "배열은 인덱스로 상수 시간에 접근 가능합니다.", true),
                            OptionResponse.create(14L, 4L, "O(log n)", "이진 탐색의 시간 복잡도입니다.", false),
                            OptionResponse.create(15L, 4L, "O(n)", "선형 탐색의 시간 복잡도입니다.", false),
                            OptionResponse.create(16L, 4L, "O(n log n)", "정렬 알고리즘의 평균 시간 복잡도입니다.", false)
                    )),
                    ProblemResponse.create(problem5, List.of()),
                    ProblemResponse.create(problem6, List.of())
            );
        }

        private final LearningAdditionalInfo learningAdditionalInfo = new LearningAdditionalInfo(1L, "스택");
        private final LessonResponse lessonResponse = LessonResponse.create(learningAdditionalInfo, problemResponses);

        @Test
        @DisplayName("Problem의 리스트가 비어있으면 예외를 반환한다.")
        void withInvalidLessonId(){
            //given
            Long lessonId = 1L;

            when(problemService.getAllProblemInLesson(lessonId)).thenThrow(new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

            //when&then
            assertThatThrownBy(() -> learningFacade.getAllProblemsInLesson(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.PROBLEM_NOT_FOUND);
        }

        @Test
        @DisplayName("Problem의 리스트가 비어있으면 예외를 반환한다.")
        void withFailedAtGetOptions(){
            //given
            Long lessonId = 1L;

            when(problemService.getAllProblemInLesson(lessonId)).thenThrow(new RestApiException(CustomErrorCode.OPTION_NOT_FOUND));

            //when&then
            assertThatThrownBy(() -> learningFacade.getAllProblemsInLesson(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.OPTION_NOT_FOUND);
        }

        @Test
        @DisplayName("문제 리스트가 조회되면 정상적으로 반환한다.")
        void withValidLessonId(){
            //given
            Long lessonId = 1L;

            when(lessonService.getLearningAdditionalInfoByLessonId(lessonId)).thenReturn(learningAdditionalInfo);
            when(problemService.getAllProblemInLesson(lessonId)).thenReturn(problemResponses);

            //when
            LessonResponse returnValue = learningFacade.getAllProblemsInLesson(lessonId);

            //then
            assertThat(returnValue).isEqualTo(lessonResponse);
            verify(lessonService, times(1)).getLearningAdditionalInfoByLessonId(lessonId);
            verify(problemService, times(1)).getAllProblemInLesson(lessonId);
        }
    }

    @Nested
    @DisplayName("문제 풀이 결과를 저장할 때,")
    class SaveLearningResult{

        private final Long userId = 1L;
        private final LearningResultSaveRequest validRequest = new LearningResultSaveRequest(
                1L, 150, 80,
                List.of(
                        new ProblemResultRequest(1L, true, 0L),
                        new ProblemResultRequest(2L, false, 2L),
                        new ProblemResultRequest(3L, true, 0L),
                        new ProblemResultRequest(4L, true, 0L),
                        new ProblemResultRequest(5L, false, 1L)
                )
        );

        private final LearningIds learningIds = new LearningIds(3L, 2L, 1L);

        @Nested
        @DisplayName("특정 학습 조회에 실패하면 예외를 반환한다.")
        class FailedAtFind{

            @Test
            @DisplayName("레슨 조회에 실패한 경우")
            void returnLesson404Exception(){
                //given
                when(lessonService.getLearningIdsByLessonId(validRequest.lessonId()))
                        .thenThrow(new RestApiException(CustomErrorCode.LESSON_NOT_FOUND));

                //when&then
                assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, validRequest))
                        .isInstanceOf(RestApiException.class)
                        .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
            }

            @Test
            @DisplayName("유닛 조회에 실패한 경우")
            void returnUnit404Exception(){
                //given
                when(lessonService.getLearningIdsByLessonId(validRequest.lessonId()))
                        .thenReturn(learningIds);
                when(chapterProgressService.ensureChapterProgress(learningIds.chapterId(), userId))
                        .thenReturn(mock(ChapterProgress.class));
                when(unitProgressService.ensureUnitProgress(learningIds.unitId(), userId))
                        .thenThrow(new RestApiException(CustomErrorCode.UNIT_NOT_FOUND));

                //when&then
                assertThatThrownBy(() -> learningFacade.saveLearningResult(userId, validRequest))
                        .isInstanceOf(RestApiException.class)
                        .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.UNIT_NOT_FOUND);
            }

            @Test
            @DisplayName("챕터 조회에 실패한 경우")
            void returnChapter404Exception(){
                //given
                when(lessonService.getLearningIdsByLessonId(validRequest.lessonId()))
                        .thenReturn(learningIds);
                when(chapterProgressService.ensureChapterProgress(learningIds.chapterId(), userId))
                        .thenThrow(new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));

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
                ChapterProgress chapterProgress = mock(ChapterProgress.class);
                UnitProgress unitProgress = mock(UnitProgress.class);

                when(lessonService.getLearningIdsByLessonId(validRequest.lessonId()))
                        .thenReturn(learningIds);
                when(chapterProgressService.ensureChapterProgress(learningIds.chapterId(), userId))
                        .thenReturn(chapterProgress);
                when(unitProgressService.ensureUnitProgress(learningIds.unitId(), userId))
                        .thenReturn(unitProgress);
                doNothing().when(problemProgressService).saveProblemResults(userId, validRequest.problemResults());
                doNothing().when(lessonProgressService).updateLessonProgress(validRequest.lessonId(), userId, validRequest.learningTime());
                when(unitProgressService.updateUnitProgress(unitProgress)).thenReturn(true);
                when(userService.updateUserLevelAndXp(userId, 20, validRequest.accuracy()))
                        .thenReturn(UserLevelResponse.create(1, 100));
                when(userLeagueService.getUserLeagueName(userId)).thenReturn("브론즈 리그");

                //when
                learningFacade.saveLearningResult(userId, validRequest);

                //then
                verify(chapterProgressService, times(1)).updateChapterProgress(chapterProgress);
                verify(publisher, times(1)).publishEvent(any(UpdateLearningEvent.class));
                verify(publisher, times(1)).publishEvent(any(LessonCompletedEvent.class));
                verify(publisher, times(1)).publishEvent(any(LessonMissionEvent.class));
                verify(publisher, times(1)).publishEvent(any(QualifiedSolvedEvent.class));
                verify(userService, times(1)).updateUserLevelAndXp(userId, 20, validRequest.accuracy());
            }

            @Test
            @DisplayName("false를 반환하면 updateChapterProgress를 호출하지 않는다.")
            void notInvokeUpdateChapterProgress(){
                //given
                ChapterProgress chapterProgress = mock(ChapterProgress.class);
                UnitProgress unitProgress = mock(UnitProgress.class);

                when(lessonService.getLearningIdsByLessonId(validRequest.lessonId()))
                        .thenReturn(learningIds);
                when(chapterProgressService.ensureChapterProgress(learningIds.chapterId(), userId))
                        .thenReturn(chapterProgress);
                when(unitProgressService.ensureUnitProgress(learningIds.unitId(), userId))
                        .thenReturn(unitProgress);
                doNothing().when(problemProgressService).saveProblemResults(userId, validRequest.problemResults());
                doNothing().when(lessonProgressService).updateLessonProgress(validRequest.lessonId(), userId, validRequest.learningTime());
                when(unitProgressService.updateUnitProgress(unitProgress)).thenReturn(false);
                when(userService.updateUserLevelAndXp(userId, 20, validRequest.accuracy()))
                        .thenReturn(UserLevelResponse.create(1, 100));
                when(userLeagueService.getUserLeagueName(userId)).thenReturn("브론즈 리그");

                //when
                learningFacade.saveLearningResult(userId, validRequest);

                //then
                verify(chapterProgressService, never()).updateChapterProgress(any());
                verify(publisher, times(1)).publishEvent(any(UpdateLearningEvent.class));
                verify(publisher, times(1)).publishEvent(any(LessonCompletedEvent.class));
                verify(publisher, times(1)).publishEvent(any(LessonMissionEvent.class));
                verify(publisher, times(1)).publishEvent(any(QualifiedSolvedEvent.class));
                verify(userService, times(1)).updateUserLevelAndXp(userId, 20, validRequest.accuracy());
            }
        }
    }
}