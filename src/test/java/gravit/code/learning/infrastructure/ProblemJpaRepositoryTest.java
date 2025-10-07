package gravit.code.learning.infrastructure;

import gravit.code.support.TCRepositoryTest;
import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@TCRepositoryTest
class ProblemJpaRepositoryTest {

    @Autowired
    private ProblemJpaRepository problemJpaRepository;

    long lessonId = 1;

    @BeforeEach
    void setUpTest(){
        Problem problem1 = Problem.create(ProblemType.OBJECTIVE, "질문1", "내용1", "정답1", lessonId);
        Problem problem2 = Problem.create(ProblemType.OBJECTIVE, "질문2", "내용2", "정답2", lessonId);
        Problem problem3 = Problem.create(ProblemType.OBJECTIVE, "질문3", "내용3", "정답3", lessonId);
        Problem problem4 = Problem.create(ProblemType.OBJECTIVE, "질문4", "내용4", "정답4", lessonId);
        Problem problem5 = Problem.create(ProblemType.OBJECTIVE, "질문5", "내용5", "정답5", lessonId);
        Problem problem6 = Problem.create(ProblemType.OBJECTIVE, "질문6", "내용6", "정답6", lessonId);
        Problem problem7 = Problem.create(ProblemType.OBJECTIVE, "질문7", "내용7", "정답7", lessonId);
        Problem problem8 = Problem.create(ProblemType.OBJECTIVE, "질문8", "내용8", "정답8", lessonId);
        Problem problem9 = Problem.create(ProblemType.OBJECTIVE, "질문9", "내용9", "정답9", lessonId);
        Problem problem10 = Problem.create(ProblemType.OBJECTIVE, "질문10", "내용10", "정답10", lessonId);
        Problem problem11 = Problem.create(ProblemType.OBJECTIVE, "질문11", "내용11", "정답11", lessonId);
        Problem problem12 = Problem.create(ProblemType.OBJECTIVE, "질문12", "내용12", "정답12", lessonId);

        List<Problem> dummyProblems = List.of(
                problem1, problem2, problem3, problem4,
                problem5, problem6, problem7, problem8,
                problem9, problem10, problem11, problem12
        );

        problemJpaRepository.saveAll(dummyProblems);
    }

    @Nested
    @DisplayName("레슨 아이디로 문제를 조회할 때")
    class FindProblemsByLessonId{

        @Test
        void 문제를_성공적으로_조회한다(){
            //given

            //when
            List<Problem> problems = problemJpaRepository.findAllByLessonId(lessonId);

            //then
            assertThat(problems).hasSize(12);

            assertThat(problems.get(0).getId()).isEqualTo(1L);
            assertThat(problems.get(0).getProblemType()).isEqualTo(ProblemType.OBJECTIVE);
            assertThat(problems.get(0).getQuestion()).isEqualTo("질문1");

            assertThat(problems.get(1).getId()).isEqualTo(2L);
            assertThat(problems.get(0).getProblemType()).isEqualTo(ProblemType.OBJECTIVE);
            assertThat(problems.get(1).getQuestion()).isEqualTo("질문2");
        }

        @Test
        void 레슨_아이디가_유효하지_않으면_빈_리스트를_반환한다(){
            //given
            long invalidLessonId = 999L;

            //when
            List<Problem> problems = problemJpaRepository.findAllByLessonId(invalidLessonId);

            //then
            assertThat(problems).isEmpty();
        }
    }
}
