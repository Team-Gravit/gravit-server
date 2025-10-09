package gravit.code.learning.infrastructure;

import gravit.code.support.TCRepositoryTest;
import gravit.code.learning.domain.Problem;
import gravit.code.learning.domain.ProblemType;
import gravit.code.learning.fixture.ProblemFixture;
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

    @Autowired
    private ProblemFixture problemFixture;

    long lessonId = 1;

    @BeforeEach
    void setUpTest(){
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
        problemFixture.객관식_문제(lessonId);
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
            assertThat(problems.get(0).getQuestion()).isEqualTo("질문");

            assertThat(problems.get(1).getId()).isEqualTo(2L);
            assertThat(problems.get(0).getProblemType()).isEqualTo(ProblemType.OBJECTIVE);
            assertThat(problems.get(1).getQuestion()).isEqualTo("질문");
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
