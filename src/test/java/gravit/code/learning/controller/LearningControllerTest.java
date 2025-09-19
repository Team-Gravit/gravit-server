package gravit.code.learning.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.common.auth.WithMockLoginUser;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.ProblemType;
import gravit.code.learning.dto.request.LearningResultSaveRequest;
import gravit.code.learning.dto.request.ProblemResultRequest;
import gravit.code.learning.dto.response.LessonResponse;
import gravit.code.learning.dto.response.ProblemResponse;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.LessonProgressSummaryResponse;
import gravit.code.progress.dto.response.UnitPageResponse;
import gravit.code.progress.dto.response.UnitProgressDetailResponse;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.service.ReportService;
import gravit.code.user.dto.response.UserLevelResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(LearningController.class)
@ActiveProfiles("test")
class LearningControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private LearningFacade learningFacade;

    @MockitoBean
    private ReportService reportService;

    @Nested
    @DisplayName("모든 챕터를 조회할 때,")
    class GetAllChapter{

        @Test
        @WithMockLoginUser
        @DisplayName("유저 아이디가 유효하지 않으면 예외를 반환한다.")
        void withInvalidUserId() throws Exception{
            //given
            long userId = 1L;

            when(learningFacade.getAllChapters(userId)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));

            //when
            ResultActions resultActions = mockMvc.perform(get("/api/v1/learning/chapters")
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("유저 아이디가 유효하면 정상적으로 반환한다.")
        void withValidUserId() throws Exception{
            //given
            long userId = 1L;
            List<ChapterProgressDetailResponse> response = List.of(
                    ChapterProgressDetailResponse.create(1L, "자료구조", "스택, 큐, 힙, 트리 등 기본적인 자료구조에 대해 학습합니다.", 12L, 8L),
                    ChapterProgressDetailResponse.create(2L, "알고리즘", "정렬, 탐색, 동적계획법 등 다양한 알고리즘을 학습합니다.", 15L, 5L),
                    ChapterProgressDetailResponse.create(3L, "데이터베이스", "관계형 데이터베이스, SQL, 트랜잭션에 대해 학습합니다.", 10L, 10L),
                    ChapterProgressDetailResponse.create(4L, "네트워크", "TCP/IP, HTTP, 소켓 프로그래밍 등 네트워크 기초를 학습합니다.", 8L, 3L),
                    ChapterProgressDetailResponse.create(5L, "운영체제", "프로세스, 스레드, 메모리 관리 등 운영체제 개념을 학습합니다.", 14L, 0L),
                    ChapterProgressDetailResponse.create(6L, "객체지향 프로그래밍", "클래스, 상속, 다형성 등 OOP 핵심 개념을 학습합니다.", 9L, 7L)
            );

            when(learningFacade.getAllChapters(userId)).thenReturn(response);

            //when
            ResultActions resultActions = mockMvc.perform(get("/api/v1/learning/chapters")
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is2xxSuccessful())
                    .andExpect(jsonPath("$[0].chapterId").value(1L))
                    .andExpect(jsonPath("$[0].name").value("자료구조"))
                    .andExpect(jsonPath("$[0].description").value("스택, 큐, 힙, 트리 등 기본적인 자료구조에 대해 학습합니다."))
                    .andExpect(jsonPath("$[0].totalUnits").value(12L))
                    .andExpect(jsonPath("$[0].completedUnits").value(8L));
        }
    }

    @Nested
    @DisplayName("특정 챕터의 모든 유닛을 조회할 때,")
    class GetAllUnitsInChapter{

        @Test
        @WithMockLoginUser
        @DisplayName("유저 아이디가 유효하지 않으면 예외를 반환한다.")
        void withInvalidUserId() throws Exception{
            //given
            long chapterId = 1L;
            long userId = 1L;

            when(learningFacade.getAllUnitsInChapter(userId, chapterId)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));

            //when
            ResultActions resultActions =  mockMvc.perform(get("/api/v1/learning/{chapterId}/units", chapterId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("유저 아이디가 유효하면 정상적으로 반환한다.")
        void withValidUserId() throws Exception{
            //given
            long chapterId = 1L;
            long userId = 1L;
            List<UnitPageResponse> response = List.of(
                    UnitPageResponse.create(
                            UnitProgressDetailResponse.create(1L, "스택", 4L, 3L),
                            List.of(
                                    LessonProgressSummaryResponse.create(1L, "스택 기본 개념", true),
                                    LessonProgressSummaryResponse.create(2L, "스택 구현하기", true),
                                    LessonProgressSummaryResponse.create(3L, "스택 활용 문제", true),
                                    LessonProgressSummaryResponse.create(4L, "스택 심화 응용", false)
                            )
                    ),
                    UnitPageResponse.create(
                            UnitProgressDetailResponse.create(2L, "큐", 3L, 1L),
                            List.of(
                                    LessonProgressSummaryResponse.create(5L, "큐 기본 개념", true),
                                    LessonProgressSummaryResponse.create(6L, "큐 구현하기", false),
                                    LessonProgressSummaryResponse.create(7L, "우선순위 큐", false)
                            )
                    ),
                    UnitPageResponse.create(
                            UnitProgressDetailResponse.create(3L, "트리", 5L, 0L),
                            List.of(
                                    LessonProgressSummaryResponse.create(8L, "트리 기본 개념", false),
                                    LessonProgressSummaryResponse.create(9L, "이진 트리", false),
                                    LessonProgressSummaryResponse.create(10L, "이진 탐색 트리", false),
                                    LessonProgressSummaryResponse.create(11L, "트리 순회", false),
                                    LessonProgressSummaryResponse.create(12L, "AVL 트리", false)
                            )
                    ),
                    UnitPageResponse.create(
                            UnitProgressDetailResponse.create(4L, "해시", 3L, 3L),
                            List.of(
                                    LessonProgressSummaryResponse.create(13L, "해시 테이블", true),
                                    LessonProgressSummaryResponse.create(14L, "해시 함수", true),
                                    LessonProgressSummaryResponse.create(15L, "충돌 해결", true)
                            )
                    )
            );

            when(learningFacade.getAllUnitsInChapter(userId, chapterId)).thenReturn(response);

            //when
            ResultActions resultActions = mockMvc.perform(get("/api/v1/learning/{chapterId}/units", chapterId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is2xxSuccessful())
                    .andExpect(jsonPath("$[0].unitProgressDetailResponse.unitId").value(1L))
                    .andExpect(jsonPath("$[0].unitProgressDetailResponse.name").value("스택"))
                    .andExpect(jsonPath("$[0].unitProgressDetailResponse.totalLesson").value(4L))
                    .andExpect(jsonPath("$[0].unitProgressDetailResponse.completedLesson").value(3L))
                    .andExpect(jsonPath("$[0].lessonProgressSummaryResponses[0].lessonId").value(1L))
                    .andExpect(jsonPath("$[0].lessonProgressSummaryResponses[0].name").value("스택 기본 개념"))
                    .andExpect(jsonPath("$[0].lessonProgressSummaryResponses[0].isCompleted").value(true))
                    .andExpect(jsonPath("$[0].lessonProgressSummaryResponses.length()").value(4));
        }
    }

    @Nested
    @DisplayName("특정 레슨의 문제를 조회할 때,")
    class GetProblemsInLesson{

        @Test
        @WithMockLoginUser
        @DisplayName("레슨 아이디가 유효하지 않으면 예외를 반환한다.")
        void withInvalidUserId() throws Exception{
            //given
            long lessonId = 1L;

            when(learningFacade.getLesson(lessonId)).thenThrow(new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

            //when
            ResultActions resultActions = mockMvc.perform(get("/api/v1/learning/{lessonId}", lessonId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("레슨 아이디가 유효하면 정상적으로 반환한다.")
        void withValidUserId() throws Exception{
            //given
            long lessonId = 1L;
            List<ProblemResponse> problemResponses = List.of(
                    ProblemResponse.builder().problemId(1L).problemType(ProblemType.SUBJECTIVE).question("스택에서 마지막에 삽입된 데이터가 가장 먼저 삭제되는 원리를 ( )라고 합니다.").content("-").answer("LIFO").options(List.of()).build(),
                    ProblemResponse.builder().problemId(2L).problemType(ProblemType.OBJECTIVE).question("스택의 주요 연산이 아닌 것은?").content("1. push, 2. pop, 3. peek, 4. enqueue").answer("4").options(List.of()).build(),
                    ProblemResponse.builder().problemId(3L).problemType(ProblemType.SUBJECTIVE).question("큐에서 데이터가 삽입되는 곳을 ( ), 삭제되는 곳을 ( )라고 합니다.").content("-").answer("rear, front").options(List.of()).build(),
                    ProblemResponse.builder().problemId(4L).problemType(ProblemType.OBJECTIVE).question("다음 중 큐의 특성을 가장 잘 설명한 것은?").content("1. LIFO 구조, 2. FIFO 구조, 3. 랜덤 접근, 4. 양방향 접근").answer("2").options(List.of()).build(),
                    ProblemResponse.builder().problemId(5L).problemType(ProblemType.SUBJECTIVE).question("이진 탐색 트리에서 중위 순회를 수행하면 노드들이 ( )된 순서로 방문됩니다.").content("-").answer("오름차순 정렬").options(List.of()).build(),
                    ProblemResponse.builder().problemId(6L).problemType(ProblemType.OBJECTIVE).question("해시 테이블에서 충돌을 해결하는 방법이 아닌 것은?").content("1. 체이닝, 2. 개방 주소법, 3. 이중 해싱, 4. 순차 탐색").answer("4").options(List.of()).build(),
                    ProblemResponse.builder().problemId(7L).problemType(ProblemType.SUBJECTIVE).question("연결 리스트에서 각 노드는 데이터와 다음 노드를 가리키는 ( )로 구성됩니다.").content("-").answer("포인터").options(List.of()).build(),
                    ProblemResponse.builder().problemId(8L).problemType(ProblemType.OBJECTIVE).question("힙 자료구조의 특징이 아닌 것은?").content("1. 완전 이진 트리, 2. 부모가 자식보다 크거나 작음, 3. 중위 순회시 정렬됨, 4. 우선순위 큐 구현").answer("3").options(List.of()).build()
            );

            LessonResponse lessonResponse = LessonResponse.create(problemResponses);

            when(learningFacade.getLesson(lessonId)).thenReturn(lessonResponse);

            //when
            ResultActions resultActions = mockMvc.perform(get("/api/v1/learning/{lessonId}", lessonId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is2xxSuccessful())
                    .andExpect(jsonPath("$.problems[0].problemId").value(1L))
                    .andExpect(jsonPath("$.problems[0].problemType").value("SUBJECTIVE"))
                    .andExpect(jsonPath("$.problems[0].question").value("스택에서 마지막에 삽입된 데이터가 가장 먼저 삭제되는 원리를 ( )라고 합니다."))
                    .andExpect(jsonPath("$.problems[0].content").value("-"))
                    .andExpect(jsonPath("$.problems[0].answer").value("LIFO"))
                    .andExpect(jsonPath("$.totalProblems").value(8));
        }
    }

    @Nested
    @DisplayName("문제 풀이 결과를 저장할 때,")
    class SaveProblemResult{

        private final LearningResultSaveRequest invalidRequest = new LearningResultSaveRequest(
                null,
                2L,
                null,
                null,
                null,
                List.of(
                        new ProblemResultRequest(null, true, 0L),
                        new ProblemResultRequest(2L, null, 2L),
                        new ProblemResultRequest(3L, false, null)
                )
        );

        private final LearningResultSaveRequest validRequest = new LearningResultSaveRequest(
                1L,
                2L,
                3L,
                120,
                85,
                List.of(
                        new ProblemResultRequest(1L, true, 0L),
                        new ProblemResultRequest(2L, false, 2L),
                        new ProblemResultRequest(3L, true, 0L),
                        new ProblemResultRequest(4L, true, 0L),
                        new ProblemResultRequest(5L, false, 1L)
                )
        );

        @Test
        @WithMockLoginUser
        @DisplayName("RequestBody가 유효하지 않으면 예외를 반환한다.")
        void withInvalidRequestBody() throws Exception {
            //given
            long userId = 1L;

            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/results")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(invalidRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("유저 아이디가 유효하지 않으면 예외를 반환한다.")
        void withInvalidUserId() throws Exception{
            //given
            long userId = 1L;

            when(learningFacade.saveLearningResult(userId, validRequest)).thenThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND));

            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/results")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(validRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("RequestBody와 유저 아이디가 유효하면 정상적으로 저장한다.")
        void withValidRequestBodyAndUserId() throws Exception{
            //given
            long userId = 1L;
            UserLevelResponse userLevelResponse = UserLevelResponse.create(3, 150);

            when(learningFacade.saveLearningResult(userId, validRequest)).thenReturn(userLevelResponse);

            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/results")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(validRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is2xxSuccessful());
        }
    }

    @Nested
    @DisplayName("문제 신고를 제출할 때,")
    class SubmitProblemReport{

        private final ProblemReportSubmitRequest invalidRequest = new ProblemReportSubmitRequest(
                null,
                "문제에 오탈자가 있습니다.",
                1L
        );

        private final ProblemReportSubmitRequest validRequest = new ProblemReportSubmitRequest(
                "TYPO_ERROR",
                "문제에 오탈자가 있습니다.",
                1L
        );

        @Test
        @WithMockLoginUser
        @DisplayName("RequestBody가 유효하지 않으면 예외를 반환한다.")
        void withInvalidRequestBody() throws Exception {
            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/reports")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(invalidRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("유저 아이디가 유효하지 않으면 예외를 반환한다.")
        void withInvalidUserId() throws Exception{
            //given
            long userId = 1L;

            doThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND)).when(reportService).submitProblemReport(userId, validRequest);

            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/reports")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(validRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("문제가 존재하지 않으면 예외를 반환한다.")
        void withInvalidProblemId() throws Exception{
            //given
            long userId = 1L;

            doThrow(new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND)).when(reportService).submitProblemReport(userId, validRequest);

            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/reports")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(validRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("이미 제출된 신고라면 예외를 반환한다.")
        void withAlreadySubmittedReport() throws Exception{
            //given
            long userId = 1L;

            doThrow(new RestApiException(CustomErrorCode.ALREADY_SUBMITTED_REPORT)).when(reportService).submitProblemReport(userId, validRequest);

            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/reports")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(validRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is4xxClientError());
        }

        @Test
        @WithMockLoginUser
        @DisplayName("RequestBody와 유저 아이디가 유효하면 정상적으로 제출한다.")
        void withValidRequestBodyAndUserId() throws Exception{
            //when
            ResultActions resultActions = mockMvc.perform(post("/api/v1/learning/reports")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(validRequest))
                    .with(csrf()));

            //then
            resultActions
                    .andDo(print())
                    .andExpect(status().is2xxSuccessful());
        }
    }

}
