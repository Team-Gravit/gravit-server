package gravit.code.learning.domain;

import gravit.code.learning.infrastructure.ProblemJpaRepository;
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
        Problem subjectiveProblem = Problem.create(
                ProblemType.SUBJECTIVE,
                "배열의 특징",
                "배열의 주요 특징 두 가지를 말하시오.",
                "연속된 메모리 공간에 저장, 인덱스를 통한 직접 접근",
                1L
        );
        problemRepository.save(subjectiveProblem);

        Problem objectiveProblem = Problem.create(
                ProblemType.OBJECTIVE,
                "배열 인덱스",
                "배열의 첫 번째 요소 인덱스는?",
                "1",
                1L
        );
        problemRepository.save(objectiveProblem);
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
            List<Problem> problems = problemRepository.findAllByLessonId(lessonId);

            //then
            assertThat(problems).isEmpty();
        }

        @Test
        @DisplayName("lessonId가 유효하면 정상적으로 반환한다.")
        void withValidLessonId(){
            //given
            Long lessonId = 1L;

            //when
            List<Problem> problems = problemRepository.findAllByLessonId(lessonId);

            //then
            assertThat(problems).hasSize(2);
        }
    }
}