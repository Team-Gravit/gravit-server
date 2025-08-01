package gravit.code.domain.learning.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.common.auth.WithMockLoginUser;
import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import gravit.code.domain.learning.controller.api.LearningController;
import gravit.code.domain.learning.dto.request.LearningResultSaveRequest;
import gravit.code.domain.learning.facade.LearningFacade;
import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import gravit.code.domain.problem.domain.ProblemType;
import gravit.code.domain.problem.dto.request.ProblemResultRequest;
import gravit.code.domain.problem.dto.response.ProblemResponse;
import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
import gravit.code.domain.unitProgress.dto.response.UnitPageResponse;
import gravit.code.domain.user.dto.response.UserLevelResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(LearningController.class)
class LearningControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private LearningFacade learningFacade;

    @Test
    @WithMockLoginUser
    @DisplayName("유효한 RequestBody로 문제 풀이 결과를 저장할 수 있다.")
    void saveLearningResultWithValidRequestBody() throws Exception {
        //given
        Long chapterId = 1L;
        Long unitId = 2L;
        Long lessonId = 3L;
        List<ProblemResultRequest> problemResults = List.of(
                new ProblemResultRequest(1L, true, 0L),
                new ProblemResultRequest(2L, true, 0L),
                new ProblemResultRequest(3L, false, 3L),
                new ProblemResultRequest(4L, true, 0L),
                new ProblemResultRequest(5L, true, 0L),
                new ProblemResultRequest(6L, true, 0L),
                new ProblemResultRequest(7L, false, 1L),
                new ProblemResultRequest(8L, true, 0L),
                new ProblemResultRequest(9L, true, 0L),
                new ProblemResultRequest(10L, true, 0L)
        );

        LearningResultSaveRequest request = new LearningResultSaveRequest(
                chapterId, unitId, lessonId, problemResults
        );
        UserLevelResponse expectedResponse = new UserLevelResponse(1, 2, 20);

        when(learningFacade.saveLearningResult(1L, request)).thenReturn(expectedResponse);

        //when&then
        mockMvc.perform(post("/api/v1/learning/results")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentLevel").value(1))
                .andExpect(jsonPath("$.xp").value(20));
    }

    @Test
    @WithMockLoginUser(userId = 1L)
    @DisplayName("유효하지 않은 RequestBody로 문제 풀이 결과를 저장하면 예외를 반환한다.")
    void saveLearningResultWithInvalidRequestBody1() throws Exception {
        //given
        Long chapterId = null;
        Long unitId = null;
        Long lessonId = null;
        List<ProblemResultRequest> problemResults = List.of(
                new ProblemResultRequest(1L, true, 0L)
        );

        LearningResultSaveRequest request = new LearningResultSaveRequest(
                chapterId, unitId, lessonId, problemResults
        );

        //when&then
        mockMvc.perform(post("/api/v1/learning/results")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andDo(print())
                .andExpect(status().is4xxClientError());
    }

    @Test
    @WithMockLoginUser(userId = 1L)
    @DisplayName("ProblemResult에 null 값이 있으면 예외를 반환한다.")
    void saveLearningResultWithInvalidProblemResults() throws Exception {
        //given
        Long chapterId = 1L;
        Long unitId = 1L;
        Long lessonId = 1L;
        List<ProblemResultRequest> problemResults = List.of(
                new ProblemResultRequest(null, true, 0L),
                new ProblemResultRequest(2L, null, 0L),
                new ProblemResultRequest(3L, false, null)
        );

        LearningResultSaveRequest request = new LearningResultSaveRequest(
                chapterId, unitId, lessonId, problemResults
        );

        //when&then
        mockMvc.perform(post("/api/v1/learning/results")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(csrf()))
                .andDo(print())
                .andExpect(status().is4xxClientError());
    }

    @Test
    @WithMockLoginUser
    @DisplayName("userId로 진행도가 포함된 챕터 정보를 조회할 수 있다.")
    void getChapterInfoWithProgressByUserId() throws Exception {
        //given
        Long userId = 1L;
        List<ChapterProgressDetailResponse> chapterProgressDetailRespons = List.of(
                new ChapterProgressDetailResponse(1L, "자료구조", "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다.", 10L, 8L),
                new ChapterProgressDetailResponse(2L, "알고리즘", "정렬, 탐색, 그래프 알고리즘에 대해 학습합니다.", 12L, 6L),
                new ChapterProgressDetailResponse(3L, "객체지향 프로그래밍", "클래스, 상속, 다형성 등 OOP 개념을 학습합니다.", 8L, 8L),
                new ChapterProgressDetailResponse(4L, "데이터베이스", "관계형 데이터베이스와 SQL 쿼리를 학습합니다.", 15L, 3L),
                new ChapterProgressDetailResponse(5L, "네트워크", "TCP/IP, HTTP, 소켓 프로그래밍을 학습합니다.", 9L, 0L),
                new ChapterProgressDetailResponse(6L, "운영체제", "프로세스, 스레드, 메모리 관리를 학습합니다.", 11L, 2L),
                new ChapterProgressDetailResponse(7L, "소프트웨어 공학", "설계 패턴, 테스트, 버전 관리를 학습합니다.", 7L, 7L),
                new ChapterProgressDetailResponse(8L, "컴퓨터 구조", "CPU, 메모리, 입출력 시스템을 학습합니다.", 6L, 1L)
        );

        when(learningFacade.getAllChapters(userId)).thenReturn(chapterProgressDetailRespons);

        //when&then
        mockMvc.perform(get("/api/v1/learning/chapters")
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()))
                .andDo(print())
                .andExpect(status().isOk());
    }

    @Test
    @WithMockLoginUser
    @DisplayName("userId와 chapterId로 진행도가 포함된 유닛 정보를 조회할 수 있다.")
    void getUnitInfoWithProgressByUserIdAndChapterId() throws Exception {
        //given
        Long userId = 1L;
        Long chapterId = 1L;
        List<UnitPageResponse> unitPageResponses = List.of(
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(1L, "스택", 4L, 4L),
                        List.of(
                                LessonProgressSummaryResponse.create(1L, "스택 기본 개념", true),
                                LessonProgressSummaryResponse.create(2L, "스택 구현하기", true),
                                LessonProgressSummaryResponse.create(3L, "스택 활용 문제", true),
                                LessonProgressSummaryResponse.create(4L, "스택 심화 응용", true)
                        )
                ),
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(2L, "큐", 3L, 2L),
                        List.of(
                                LessonProgressSummaryResponse.create(5L, "큐 기본 개념", true),
                                LessonProgressSummaryResponse.create(6L, "큐 구현하기", true),
                                LessonProgressSummaryResponse.create(7L, "우선순위 큐", false)
                        )
                ),
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(3L, "연결 리스트", 5L, 1L),
                        List.of(
                                LessonProgressSummaryResponse.create(8L, "연결 리스트 기본", true),
                                LessonProgressSummaryResponse.create(9L, "단일 연결 리스트", false),
                                LessonProgressSummaryResponse.create(10L, "이중 연결 리스트", false),
                                LessonProgressSummaryResponse.create(11L, "원형 연결 리스트", false),
                                LessonProgressSummaryResponse.create(12L, "연결 리스트 응용", false)
                        )
                ),
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(4L, "트리", 6L, 0L),
                        List.of(
                                LessonProgressSummaryResponse.create(13L, "트리 기본 개념", false),
                                LessonProgressSummaryResponse.create(14L, "이진 트리", false),
                                LessonProgressSummaryResponse.create(15L, "이진 탐색 트리", false),
                                LessonProgressSummaryResponse.create(16L, "AVL 트리", false),
                                LessonProgressSummaryResponse.create(17L, "트리 순회", false),
                                LessonProgressSummaryResponse.create(18L, "트리 응용 문제", false)
                        )
                ),
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(5L, "해시", 4L, 3L),
                        List.of(
                                LessonProgressSummaryResponse.create(19L, "해시 테이블 개념", true),
                                LessonProgressSummaryResponse.create(20L, "해시 함수", true),
                                LessonProgressSummaryResponse.create(21L, "충돌 해결 방법", true),
                                LessonProgressSummaryResponse.create(22L, "해시 응용", false)
                        )
                ),
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(6L, "힙", 3L, 0L),
                        List.of(
                                LessonProgressSummaryResponse.create(23L, "힙 자료구조", false),
                                LessonProgressSummaryResponse.create(24L, "최대힙과 최소힙", false),
                                LessonProgressSummaryResponse.create(25L, "힙 정렬", false)
                        )
                ),
                UnitPageResponse.create(
                        UnitProgressDetailResponse.create(7L, "그래프", 7L, 2L),
                        List.of(
                                LessonProgressSummaryResponse.create(26L, "그래프 기본 개념", true),
                                LessonProgressSummaryResponse.create(27L, "그래프 표현 방법", true),
                                LessonProgressSummaryResponse.create(28L, "깊이 우선 탐색", false),
                                LessonProgressSummaryResponse.create(29L, "너비 우선 탐색", false),
                                LessonProgressSummaryResponse.create(30L, "최단 경로 알고리즘", false),
                                LessonProgressSummaryResponse.create(31L, "최소 신장 트리", false),
                                LessonProgressSummaryResponse.create(32L, "그래프 응용 문제", false)
                        )
                )
        );

        when(learningFacade.getAllUnitsInChapter(userId, chapterId)).thenReturn(unitPageResponses);

        //when&then
        mockMvc.perform(get("/api/v1/learning/{chapterId}/units", chapterId)
                    .contentType(MediaType.APPLICATION_JSON)
                    .with(csrf()))
                .andDo(print())
                .andExpect(status().isOk());

    }

    @Test
    @WithMockLoginUser
    @DisplayName("lessonId로 레슨에 포함된 문제를 조회할 수 있다.")
    void getProblemsByLessonId() throws Exception {
        //given
        Long lessonId = 1L;
        List<ProblemResponse> problemInfos = List.of(
                ProblemResponse.create(
                        1L,
                        ProblemType.FILL_BLANK,
                        "스택에서 마지막에 삽입된 데이터가 가장 먼저 삭제되는 원리를 ( )라고 합니다.",
                        "-",
                        "LIFO"
                ),
                ProblemResponse.create(
                        2L,
                        ProblemType.SELECT_DESCRIPTION,
                        "스택의 주요 연산이 아닌 것은?",
                        "1. push, 2. pop, 3. peek, 4. enqueue",
                        "4"
                ),
                ProblemResponse.create(
                        3L,
                        ProblemType.FILL_BLANK,
                        "큐에서 데이터가 삽입되는 곳을 ( ), 삭제되는 곳을 ( )라고 합니다.",
                        "-",
                        "rear, front"
                ),
                ProblemResponse.create(
                        4L,
                        ProblemType.SELECT_DESCRIPTION,
                        "다음 중 큐의 특성을 가장 잘 설명한 것은?",
                        "1. LIFO 구조, 2. FIFO 구조, 3. 랜덤 접근, 4. 양방향 접근",
                        "2"
                ),
                ProblemResponse.create(
                        5L,
                        ProblemType.FILL_BLANK,
                        "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.",
                        "-",
                        "오름차순 정렬"
                ),
                ProblemResponse.create(
                        6L,
                        ProblemType.SELECT_DESCRIPTION,
                        "트리에서 루트 노드의 높이는?",
                        "1. 0, 2. 1, 3. 트리의 깊이, 4. 노드 개수",
                        "1"
                ),
                ProblemResponse.create(
                        7L,
                        ProblemType.FILL_BLANK,
                        "해시 테이블에서 서로 다른 키가 동일한 해시 값을 가지는 현상을 ( )라고 합니다.",
                        "-",
                        "충돌"
                ),
                ProblemResponse.create(
                        8L,
                        ProblemType.SELECT_DESCRIPTION,
                        "해시 충돌을 해결하는 방법이 아닌 것은?",
                        "1. 체이닝, 2. 개방 주소법, 3. 이중 해싱, 4. 순차 탐색",
                        "4"
                ),
                ProblemResponse.create(
                        9L,
                        ProblemType.FILL_BLANK,
                        "연결 리스트에서 각 노드는 데이터와 다음 노드를 가리키는 ( )로 구성됩니다.",
                        "-",
                        "포인터"
                ),
                ProblemResponse.create(
                        10L,
                        ProblemType.SELECT_DESCRIPTION,
                        "힙(Heap) 자료구조의 특징이 아닌 것은?",
                        "1. 완전 이진 트리, 2. 부모가 자식보다 크거나 작음, 3. 중위 순회시 정렬됨, 4. 우선순위 큐 구현",
                        "3"
                ),
                ProblemResponse.create(
                        11L,
                        ProblemType.FILL_BLANK,
                        "그래프에서 모든 정점을 한 번씩 방문하는 탐색 방법 중 스택을 사용하는 것은 ( )입니다.",
                        "-",
                        "DFS"
                ),
                ProblemResponse.create(
                        12L,
                        ProblemType.SELECT_DESCRIPTION,
                        "다음 중 시간 복잡도가 O(log n)인 연산은?",
                        "1. 배열에서 순차 탐색, 2. 연결 리스트 삽입, 3. 이진 탐색 트리 탐색, 4. 해시 테이블 충돌시 탐색",
                        "3"
                )
        );

        when(learningFacade.getAllProblemsInLesson(lessonId)).thenReturn(problemInfos);

        //when&then
        mockMvc.perform(get("/api/v1/learning/{lessonId}/problems", lessonId)
                .contentType(MediaType.APPLICATION_JSON)
                .with(csrf()))
                .andDo(print())
                .andExpect(status().isOk());
    }
}