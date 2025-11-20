//package gravit.code.learning.service;
//
//import gravit.code.global.exception.domain.CustomErrorCode;
//import gravit.code.global.exception.domain.RestApiException;
//import gravit.code.learning.domain.Learning;
//import gravit.code.learning.domain.LearningRepository;
//import gravit.code.learning.domain.LessonRepository;
//import gravit.code.learning.fixture.LearningFixture;
//import gravit.code.learning.domain.LessonSubmissionRepository;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//import org.springframework.data.domain.PageRequest;
//
//import java.util.Collections;
//import java.util.List;
//import java.util.Optional;
//
//import static org.assertj.core.api.Assertions.assertThatThrownBy;
//import static org.mockito.ArgumentMatchers.anyList;
//import static org.mockito.Mockito.*;
//
//@ExtendWith(MockitoExtension.class)
//class LearningServiceUnitTest {
//
//    @Mock
//    private LearningRepository learningRepository;
//
//    @Mock
//    private LessonRepository lessonRepository;
//
//    @Mock
//    private LessonSubmissionRepository lessonProgressRepository;
//
//    @InjectMocks
//    private LearningService learningService;
//
//    @Test
//    void 연속학습일수_업데이트에_성공한다(){
//        //given
//        Learning learning1 = spy(LearningFixture.당일_학습_완료(1L));
//        Learning learning2 = spy(LearningFixture.당일_학습_완료(2L));
//        Learning learning3 = spy(LearningFixture.당일_학습_완료(3L));
//
//        Learning learning4 = spy(LearningFixture.당일_학습_미완료(4L));
//        Learning learning5 = spy(LearningFixture.당일_학습_미완료(5L));
//        Learning learning6 = spy(LearningFixture.당일_학습_미완료(6L));
//
//        when(learningRepository.findAll(PageRequest.of(0,10)))
//                .thenReturn(List.of(learning1, learning2, learning3, learning4, learning5, learning6));
//        when(learningRepository.findAll(PageRequest.of(1,10)))
//                .thenReturn(Collections.emptyList());
//
//        //when
//        learningService.updateConsecutiveDays();
//
//        //then
//        verify(learning1).updateConsecutiveDays();
//        verify(learning2).updateConsecutiveDays();
//        verify(learning3).updateConsecutiveDays();
//        verify(learning4).updateConsecutiveDays();
//        verify(learning5).updateConsecutiveDays();
//        verify(learning6).updateConsecutiveDays();
//        verify(learningRepository).saveAll(anyList());
//    }
//
//    @Nested
//    @DisplayName("사용자가 학습을 완료하여 학습 정보를 업데이트할 때")
//    class UpdateLearning{
//
//        @Test
//        void 학습_정보_업데이트에_성공한다(){
//            //given
//            long userId = 1L;
//            long chapterId = 1L;
//
//            Learning learning = spy(LearningFixture.기본_학습_정보(userId));
//
//            long totalLesson = 20;
//            long solvedLesson = 10;
//
//            when(learningRepository.findByUserId(userId))
//                    .thenReturn(Optional.ofNullable(learning));
//
//            when(lessonRepository.count()).thenReturn(totalLesson);
//            when(lessonProgressRepository.countByUserId(userId)).thenReturn(solvedLesson);
//
//            //when
//            learningService.updateLearningStatus(userId, chapterId);
//
//            //then
//            verify(learningRepository).findByUserId(userId);
//            verify(lessonRepository).count();
//            verify(lessonProgressRepository).countByUserId(userId);
//            verify(learning).updateLearningStatus(chapterId, 50);
//            verify(learningRepository).save(learning);
//        }
//
//        @Test
//        void 학습_정보_조회에_실패하면_예외를_반환한다(){
//            //given
//            long userId = 1L;
//            long chapterId = 1L;
//
//            when(learningRepository.findByUserId(userId))
//                    .thenReturn(Optional.empty());
//
//            //when & then
//            assertThatThrownBy(() -> learningService.updateLearningStatus(userId, chapterId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LEARNING_NOT_FOUND);
//        }
//    }
//
//    @Test
//    void 학습_정보_생성에_성공한다(){
//        //given
//        long userId = 1L;
//
//        //when
//        learningService.createLearning(userId);
//
//        //then
//        verify(learningRepository).save(any(Learning.class));
//    }
//}
