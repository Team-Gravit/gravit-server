//package gravit.code.learning.scheduler;
//
//import gravit.code.learning.service.LearningService;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import static org.mockito.Mockito.verify;
//
//@ExtendWith(MockitoExtension.class)
//class LearningSchedulerTest {
//
//    @Mock
//    private LearningService learningService;
//
//    @InjectMocks
//    private LearningScheduler learningScheduler;
//
//    @Test
//    void 연속학습일수_업데이트에_성공한다(){
//        //given
//
//        //when
//        learningScheduler.updateConsecutiveDays();
//
//        //then
//        verify(learningService).updateConsecutiveDays();
//    }
//
//}
