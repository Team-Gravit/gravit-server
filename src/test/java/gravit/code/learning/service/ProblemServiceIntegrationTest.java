//package gravit.code.learning.service;
//
//import gravit.code.option.domain.Option;
//import gravit.code.option.domain.OptionRepository;
//import gravit.code.problem.domain.Problem;
//import gravit.code.problem.domain.ProblemRepository;
//import gravit.code.problem.dto.response.ProblemResponse;
//import gravit.code.learning.fixture.OptionFixture;
//import gravit.code.learning.fixture.ProblemFixture;
//import gravit.code.support.TCSpringBootTest;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//
//import java.util.List;
//
//import static org.assertj.core.api.Assertions.assertThat;
//
//@TCSpringBootTest
//class ProblemServiceIntegrationTest {
//
//    @Autowired
//    private ProblemRepository problemRepository;
//
//    @Autowired
//    private OptionRepository optionRepository;
//
//    @Autowired
//    private ProblemService problemService;
//
//    Problem objectiveProblem1;
//    Problem objectiveProblem2;
//    Problem objectiveProblem3;
//
//    Option option1ForProblem1;
//    Option option2ForProblem1;
//    Option option3ForProblem1;
//    Option option4ForProblem1;
//
//    Option option1ForProblem2;
//    Option option2ForProblem2;
//    Option option3ForProblem2;
//    Option option4ForProblem2;
//
//    Option option1ForProblem3;
//    Option option2ForProblem3;
//    Option option3ForProblem3;
//    Option option4ForProblem3;
//
//    Problem subjectiveProblem1;
//    Problem subjectiveProblem2;
//    Problem subjectiveProblem3;
//
//    @BeforeEach
//    void setUp(){
//        objectiveProblem1 = ProblemFixture.객관식_문제(1L);
//        objectiveProblem2 = ProblemFixture.객관식_문제(1L);
//        objectiveProblem3 = ProblemFixture.객관식_문제(1L);
//
//        problemRepository.saveAll(List.of(objectiveProblem1, objectiveProblem2, objectiveProblem3));
//
//        option1ForProblem1 = OptionFixture.정답_선지(objectiveProblem1.getId());
//        option2ForProblem1 = OptionFixture.오답_선지(objectiveProblem1.getId());
//        option3ForProblem1 = OptionFixture.오답_선지(objectiveProblem1.getId());
//        option4ForProblem1 = OptionFixture.오답_선지(objectiveProblem1.getId());
//
//        option1ForProblem2 = OptionFixture.정답_선지(objectiveProblem2.getId());
//        option2ForProblem2 = OptionFixture.오답_선지(objectiveProblem2.getId());
//        option3ForProblem2 = OptionFixture.오답_선지(objectiveProblem2.getId());
//        option4ForProblem2 = OptionFixture.오답_선지(objectiveProblem2.getId());
//
//        option1ForProblem3 = OptionFixture.정답_선지(objectiveProblem3.getId());
//        option2ForProblem3 = OptionFixture.오답_선지(objectiveProblem3.getId());
//        option3ForProblem3 = OptionFixture.오답_선지(objectiveProblem3.getId());
//        option4ForProblem3 = OptionFixture.오답_선지(objectiveProblem3.getId());
//
//        optionRepository.saveAll(List.of(
//                option1ForProblem1, option2ForProblem1, option3ForProblem1, option4ForProblem1,
//                option1ForProblem2, option2ForProblem2, option3ForProblem2, option4ForProblem2,
//                option1ForProblem3, option2ForProblem3, option3ForProblem3, option4ForProblem3
//        ));
//
//        subjectiveProblem1 = ProblemFixture.주관식_문제(1L);
//        subjectiveProblem2 = ProblemFixture.주관식_문제(1L);
//        subjectiveProblem3 = ProblemFixture.주관식_문제(1L);
//
//        problemRepository.saveAll(List.of(subjectiveProblem1, subjectiveProblem2, subjectiveProblem3));
//    }
//
//    @Test
//    void 성공적으로_문제를_조회한다(){
//        //given
//        long lessonId = 1L;
//
//        //when
//        List<ProblemResponse> problemResponses = problemService.getAllProblemInLesson(lessonId);
//
//        //then
//        assertThat(problemResponses).hasSize(6);
//        assertThat(problemResponses.get(0)).satisfies(p -> {
//            assertThat(p.problemId()).isEqualTo(objectiveProblem1.getId());
//            assertThat(p.answer()).isEqualTo(objectiveProblem1.getAnswer());
//            assertThat(p.options()).hasSize(4);
//        });
//        assertThat(problemResponses.get(3)).satisfies(p -> {
//            assertThat(p.problemId()).isEqualTo(subjectiveProblem1.getId());
//            assertThat(p.answer()).isEqualTo(subjectiveProblem1.getAnswer());
//            assertThat(p.options()).isEmpty();
//        });
//    }
//}
