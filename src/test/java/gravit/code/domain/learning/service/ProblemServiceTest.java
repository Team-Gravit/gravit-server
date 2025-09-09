package gravit.code.domain.learning.service;

import gravit.code.domain.learning.domain.ProblemRepository;
import gravit.code.domain.learning.domain.ProblemType;
import gravit.code.domain.learning.dto.response.ProblemResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProblemServiceTest {

    @Mock
    private ProblemRepository problemRepository;

    @InjectMocks
    private ProblemService problemService;

    @Nested
    @DisplayName("모든 문제를 조회할 떄,")
    class getAllProblems{

        private final List<ProblemResponse> problemResponses = List.of(
                ProblemResponse.create(
                        1L,
                        ProblemType.FILL_BLANK,
                        "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.",
                        "-",
                        "오름차순 정렬"
                ),
                ProblemResponse.create(
                        2L,
                        ProblemType.SELECT_DESCRIPTION,
                        "해시 테이블에서 서로 다른 키가 동일한 해시 값을 가지는 충돌(Collision) 현상을 해결하기 위해 연결 리스트로 같은 해시 값의 데이터들을 체인 형태로 연결하는 기법은?",
                        "-",
                        "체이닝"
                ),
                ProblemResponse.create(
                        3L,
                        ProblemType.FILL_BLANK,
                        "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.",
                        "1. 오름차순 정렬, 2. 내림차순 정렬, 3. 무작위, 4. 역정렬",
                        "1"
                ),
                ProblemResponse.create(
                        4L,
                        ProblemType.SELECT_DESCRIPTION,
                        "해시 테이블에서 서로 다른 키가 동일한 해시 값을 가지는 충돌(Collision) 현상을 해결하기 위해 연결 리스트로 같은 해시 값의 데이터들을 체인 형태로 연결하는 기법은?",
                        "1. 선형 탐사법, 2. 이차 탐사법, 3. 체이닝, 4. 이중 해싱",
                        "1"
                )
        );

        @Test
        @DisplayName("lessonId가 유효하면 정상적으로 반환한다.")
        void getLessonProblemsByExistLessonId(){
            // given
            Long lessonId = 1L;

            when(problemRepository.findAllProblemByLessonId(lessonId)).thenReturn(problemResponses);

            // when
            List<ProblemResponse> actualResponse = problemService.getAllProblem(lessonId);

            // then
            assertThat(actualResponse).hasSize(problemResponses.size());
        }

        @Test
        @DisplayName("lessonId가 유효하지 않으면 빈 리스트가 반환되어 예외를 반환한다.")
        void getLessonProblemByNonExistLessonId(){
            // given
            Long lessonId = 999L;
            when(problemRepository.findAllProblemByLessonId(lessonId)).thenReturn(List.of());

            // when & then
            assertThatThrownBy(() -> problemService.getAllProblem(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.PROBLEM_NOT_FOUND);
        }
    }
}