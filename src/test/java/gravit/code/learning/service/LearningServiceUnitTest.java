package gravit.code.learning.service;

import gravit.code.learning.domain.LearningRepository;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.progress.domain.LessonProgressRepository;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class LearningServiceUnitTest {

    @Mock
    private LearningRepository learningRepository;

    @Mock
    private LessonRepository lessonRepository;

    @Mock
    private LessonProgressRepository lessonProgressRepository;

    @InjectMocks
    private LearningService learningService;

//    @Autowired
//    private LearningFixture learningFixture;
//
//    @Test
//    void 연속학습일수_업데이트에_성공한다(){
//        //given
//        Learning learning = spy(Learning);
//    }
}