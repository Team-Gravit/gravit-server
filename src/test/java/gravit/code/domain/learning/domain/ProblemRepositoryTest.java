package gravit.code.domain.learning.domain;

import gravit.code.domain.learning.dto.response.ProblemResponse;
import gravit.code.domain.learning.infrastructure.ProblemJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@ActiveProfiles("test")
class ProblemRepositoryTest {

    @Autowired
    private ProblemJpaRepository problemRepository;

    @BeforeEach
    void setUp() {
        Problem subjectiveProblemFillBlankType = Problem.create(
            ProblemType.FILL_BLANK,
                "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.",
                "오름차순 정렬",
                "-",
                1L
        );
        problemRepository.save(subjectiveProblemFillBlankType);

        Problem subjectiveProblemSelectDescriptionType = Problem.create(
                ProblemType.SELECT_DESCRIPTION,
                "해시 테이블에서 서로 다른 키가 동일한 해시 값을 가지는 충돌(Collision) 현상을 해결하기 위해 연결 리스트로 같은 해시 값의 데이터들을 체인 형태로 연결하는 기법은?",
                "체이닝",
                "-",
                1L
        );
        problemRepository.save(subjectiveProblemSelectDescriptionType);

        Problem multipleChoiceProblemFillBlankType = Problem.create(
                ProblemType.FILL_BLANK,
                "이진 탐색 트리에서 중위 순회(In-order traversal)를 수행하면 노드들이 ( )된 순서로 방문됩니다.",
                "1",
                "1. 오름차순 정렬, 2. 내림차순 정렬, 3. 무작위, 4. 역정렬",
                1L
        );
        problemRepository.save(multipleChoiceProblemFillBlankType);

        Problem multipleChoiceProblemSelectDescriptionType = Problem.create(
                ProblemType.SELECT_DESCRIPTION,
                "해시 테이블에서 서로 다른 키가 동일한 해시 값을 가지는 충돌(Collision) 현상을 해결하기 위해 연결 리스트로 같은 해시 값의 데이터들을 체인 형태로 연결하는 기법은?",
                "1",
                "1. 선형 탐사법, 2. 이차 탐사법, 3. 체이닝, 4. 이중 해싱",
                1L
        );
        problemRepository.save(multipleChoiceProblemSelectDescriptionType);
    }

    @Nested
    @DisplayName("Problem을 조회할 때,")
    class findProblem{

        @Test
        @DisplayName("lessonId가 유효하지 않으면 빈 리스트를 반환한다.")
        void withInvalidLessonId(){
            //given
            Long lessonId = 2L;

            //when
            List<ProblemResponse> problemResponses = problemRepository.findAllProblemByLessonId(lessonId);

            //then
            assertThat(problemResponses).isEmpty();
        }

        @Test
        @DisplayName("lessonId가 유효하면 정상적으로 반환한다.")
        void withValidLEssonId(){
            //given
            Long lessonId = 1L;

            //when
            List<ProblemResponse> problemResponses = problemRepository.findAllProblemByLessonId(lessonId);

            //then
            assertThat(problemResponses).hasSize(4);
        }
    }
}