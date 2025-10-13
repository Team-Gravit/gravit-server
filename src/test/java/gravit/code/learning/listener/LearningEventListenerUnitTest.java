package gravit.code.learning.listener;

import gravit.code.global.event.badge.StreakUpdatedEvent;
import gravit.code.learning.dto.StreakDto;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.learning.dto.event.UpdateLearningEvent;
import gravit.code.learning.service.LearningService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LearningEventListenerUnitTest {
    @Mock
    private LearningService learningService;

    @Mock
    private ApplicationEventPublisher publisher;

    @InjectMocks
    private LearningEventListener learningEventListener;

    @Nested
    @DisplayName("유저의 학습정보를 업데이트하는 이벤트가 발행되면")
    class UpdateLearning{

        @Test
        void 유저_학습정보를_성공적으로_업데이트한다(){
            //given
            long userId = 1L;
            long chapterId = 1L;

            int before = 0;
            int after = 1;

            UpdateLearningEvent updateLearningEvent = UpdateLearningEvent.of(userId, chapterId);
            StreakUpdatedEvent streakUpdatedEvent = StreakUpdatedEvent.of(userId, after);
            StreakDto streakDto = StreakDto.of(before, after);

            when(learningService.updateLearningStatus(userId, chapterId))
                    .thenReturn(streakDto);

            //when
            learningEventListener.updateLearning(updateLearningEvent);

            //then
            verify(learningService).updateLearningStatus(userId, chapterId);
            verify(publisher).publishEvent(streakUpdatedEvent);
        }

        @Test
        void 연속학습일수가_업데이트되지_않으면_새로운_이벤트를_발행한다(){
            //given
            long userId = 1L;
            long chapterId = 1L;

            int before = 1;
            int after = 1;

            UpdateLearningEvent updateLearningEvent = UpdateLearningEvent.of(userId, chapterId);
            StreakUpdatedEvent streakUpdatedEvent = StreakUpdatedEvent.of(userId, after);
            StreakDto streakDto = StreakDto.of(before, after);

            when(learningService.updateLearningStatus(userId, chapterId))
                    .thenReturn(streakDto);

            //when
            learningEventListener.updateLearning(updateLearningEvent);

            //then
            verify(learningService).updateLearningStatus(userId, chapterId);
            verify(publisher, never()).publishEvent(streakUpdatedEvent);
        }
    }

    @Test
    void 유저_학습정보_생성_이벤트가_발행되면_유저_학습정보를_성공적으로_생성한다(){
        //given
        long userId = 1L;

        CreateLearningEvent createLearningEvent = CreateLearningEvent.of(userId);

        //when
        learningEventListener.createLearning(createLearningEvent);

        //then
        verify(learningService).createLearning(createLearningEvent.userId());
    }
}