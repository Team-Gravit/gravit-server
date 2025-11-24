//package gravit.code.learning.service;
//
//import gravit.code.option.domain.Option;
//import gravit.code.option.domain.OptionRepository;
//import gravit.code.problem.domain.Problem;
//import gravit.code.problem.domain.ProblemRepository;
//import gravit.code.option.dto.response.OptionResponse;
//import gravit.code.learning.fixture.OptionFixture;
//import gravit.code.learning.fixture.ProblemFixture;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import java.util.List;
//
//import static org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//@ExtendWith(MockitoExtension.class)
//class ProblemServiceUnitTest {
//
//    @Mock
//    private ProblemRepository problemRepository;
//
//    @Mock
//    private OptionRepository optionRepository;
//
//    @InjectMocks
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
//        objectiveProblem1 = ProblemFixture.저장된_객관식_문제(1L, 1L);
//        objectiveProblem2 = ProblemFixture.저장된_객관식_문제(2L, 1L);
//        objectiveProblem3 = ProblemFixture.저장된_객관식_문제(3L, 1L);
//        subjectiveProblem1 = ProblemFixture.저장된_주관식_문제(4L, 1L);
//        subjectiveProblem2 = ProblemFixture.저장된_주관식_문제(5L, 1L);
//        subjectiveProblem3 = ProblemFixture.저장된_주관식_문제(6L, 1L);
//
//        option1ForProblem1 = OptionFixture.저장된_정답_선지(1L, objectiveProblem1.getId());
//        option2ForProblem1 = OptionFixture.저장된_오답_선지(2L, objectiveProblem1.getId());
//        option3ForProblem1 = OptionFixture.저장된_오답_선지(3L, objectiveProblem1.getId());
//        option4ForProblem1 = OptionFixture.저장된_오답_선지(4L, objectiveProblem1.getId());
//
//        option1ForProblem2 = OptionFixture.저장된_정답_선지(5L, objectiveProblem2.getId());
//        option2ForProblem2 = OptionFixture.저장된_오답_선지(6L, objectiveProblem2.getId());
//        option3ForProblem2 = OptionFixture.저장된_오답_선지(7L, objectiveProblem2.getId());
//        option4ForProblem2 = OptionFixture.저장된_오답_선지(8L, objectiveProblem2.getId());
//
//        option1ForProblem3 = OptionFixture.저장된_정답_선지(9L, objectiveProblem3.getId());
//        option2ForProblem3 = OptionFixture.저장된_오답_선지(10L, objectiveProblem3.getId());
//        option3ForProblem3 = OptionFixture.저장된_오답_선지(11L, objectiveProblem3.getId());
//        option4ForProblem3 = OptionFixture.저장된_오답_선지(12L, objectiveProblem3.getId());
//    }
//
//    @Test
//    void 성공적으로_문제를_조회한다(){
//        //given
//        long lessonId = 1L;
//
//        when(problemRepository.findAllProblemByLessonId(lessonId))
//                .thenReturn(List.of(
//                        objectiveProblem1, objectiveProblem2, objectiveProblem3,
//                        subjectiveProblem1, subjectiveProblem2, subjectiveProblem3
//                ));
//        when(optionRepository.findAllByProblemIdInIds(List.of(objectiveProblem1.getId(),  objectiveProblem2.getId(), objectiveProblem3.getId())))
//                .thenReturn(List.of(
//                        OptionResponse.from(option1ForProblem1), OptionResponse.from(option2ForProblem1), OptionResponse.from(option3ForProblem1), OptionResponse.from(option4ForProblem1),
//                        OptionResponse.from(option1ForProblem2), OptionResponse.from(option2ForProblem2), OptionResponse.from(option3ForProblem2), OptionResponse.from(option4ForProblem2),
//                        OptionResponse.from(option1ForProblem3), OptionResponse.from(option2ForProblem3), OptionResponse.from(option3ForProblem3), OptionResponse.from(option4ForProblem3)
//                ));
//
//        //when
//        problemService.getAllProblemInLesson(lessonId);
//
//        //then
//        verify(problemRepository).findAllProblemByLessonId(lessonId);
//        verify(optionRepository).findAllByProblemIdInIds(List.of(objectiveProblem1.getId(),  objectiveProblem2.getId(), objectiveProblem3.getId()));
//    }
//}