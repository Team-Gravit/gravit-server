package gravit.code.recentLearning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.recentLearning.domain.RecentLearningRepository;
import gravit.code.recentLearning.dto.response.RecentLearningSummaryResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RecentLearningServiceTest {

    @Mock
    private RecentLearningRepository recentLearningRepository;

    @InjectMocks
    private RecentLearningService recentLearningService;

//    @Nested
//    @DisplayName("최근 학습를 업데이트할 때,")
//    class UpdateRecentLearning {
//
//        @Test
//        @DisplayName("최근 학습 조회에 실패하면 객체를 생성하여 업데이트한다.")
//        void updateNewRecentLearning() {
//            //given
//            Long userId = 1L;
//
//            UpdateRecentLearningEvent updateRecentLearningEvent = mock(UpdateRecentLearningEvent.class);
//            RecentLearning recentLearning = mock(RecentLearning.class);
//
//            when(recentLearningRepository.findByUserId(userId)).thenReturn(Optional.empty());
//
//            try(MockedStatic<RecentLearning> mockedStatic = mockStatic(RecentLearning.class)){
//
//                mockedStatic.when(() -> RecentLearning.init(userId))
//                        .thenReturn(recentLearning);
//
//                //when
//                recentLearningEventListener.updateRecentLearning(userId, updateRecentLearningEvent);
//
//                //then
//                mockedStatic.verify(() -> RecentLearning.init(userId));
//                verify(recentLearning).update(updateRecentLearningEvent);
//                verify(recentLearningRepository).save(recentLearning);
//
//            }
//        }
//
//        @Test
//        @DisplayName("최근 학습 조회에 성공하면 조회된 객체를 업데이트한다.")
//        void updateExistingRecentLearning() {
//            //given
//            Long userId = 1L;
//            ChapterSummaryResponse chapterSummaryResponse = mock(ChapterSummaryResponse.class);
//            RecentLearning recentLearning = mock(RecentLearning.class);
//
//            when(recentLearningRepository.findByUserId(userId)).thenReturn(Optional.of(recentLearning));
//
//            //when
//            recentLearningService.updateRecentLearning(userId, chapterSummaryResponse);
//
//            //then
//            verify(recentLearning).update(chapterSummaryResponse);
//            verify(recentLearningRepository).save(recentLearning);
//        }
//    }

    @Nested
    @DisplayName("최근 학습을 조회할 때,")
    class GetRecentLearning{

        @Test
        @DisplayName("조회에 실패하면 예외를 반환한다.")
        void throwExceptionWhenFailedAtFind(){
            //given
            Long userId = 1L;

            when(recentLearningRepository.findRecentLearningSummaryByUserId(userId)).thenReturn(Optional.empty());

            //when&then
            assertThatThrownBy(() -> recentLearningService.getRecentLearningSummary(userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.RECENT_LEARNING_INFO_NOT_FOUND);
        }

        @Test
        @DisplayName("조회에 성공하면 정상적으로 반환한다.")
        void returnRecentLearningSummary(){
            //given
            Long userId = 1L;
            RecentLearningSummaryResponse recentLearningSummaryResponse = mock(RecentLearningSummaryResponse.class);

            when(recentLearningRepository.findRecentLearningSummaryByUserId(userId)).thenReturn(Optional.of(recentLearningSummaryResponse));

            //when
            RecentLearningSummaryResponse response = recentLearningService.getRecentLearningSummary(userId);

            //then
            assertThat(response).isInstanceOf(RecentLearningSummaryResponse.class);
        }
    }
}