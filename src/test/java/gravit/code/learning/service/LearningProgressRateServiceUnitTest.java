package gravit.code.learning.service;

import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LearningProgressRateServiceUnitTest {

    @InjectMocks
    private LearningProgressRateService learningProgressRateService;

    @Mock
    private LessonRepository lessonRepository;

    @Mock
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("챕터 진행률을 조회할 때")
    class GetChapterProgress {

        @Test
        void 풀이한_레슨이_없으면_0을_반환한다() {
            // given
            long chapterId = 1L;
            long userId = 1L;

            when(lessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId(chapterId, userId)).thenReturn(0);

            // when
            double result = learningProgressRateService.getChapterProgress(chapterId, userId);

            // then
            assertThat(result).isEqualTo(0.0);
        }

        @Test
        void 일부_레슨을_풀었으면_진행률을_반환한다() {
            // given
            long chapterId = 1L;
            long userId = 1L;

            when(lessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId(chapterId, userId)).thenReturn(1);
            when(lessonRepository.countTotalLessonByChapterId(chapterId)).thenReturn(3);

            // when
            double result = learningProgressRateService.getChapterProgress(chapterId, userId);

            // then
            assertThat(result).isEqualTo(33.0); // floor(33.33...)
        }

        @Test
        void 모든_레슨을_풀었으면_100을_반환한다() {
            // given
            long chapterId = 1L;
            long userId = 1L;

            when(lessonSubmissionRepository.countSolvedLessonByChapterIdAndUserId(chapterId, userId)).thenReturn(3);
            when(lessonRepository.countTotalLessonByChapterId(chapterId)).thenReturn(3);

            // when
            double result = learningProgressRateService.getChapterProgress(chapterId, userId);

            // then
            assertThat(result).isEqualTo(100.0);
        }
    }

    @Nested
    @DisplayName("진행률을 계산할 때")
    class CalculateProgressRate {

        @Test
        void 풀이한_레슨이_없으면_0을_반환한다() {
            // given
            long solvedLessonCount = 0L;
            long totalLessonCount = 3L;

            // when
            double result = learningProgressRateService.calculateProgressRate(solvedLessonCount, totalLessonCount);

            // then
            assertThat(result).isEqualTo(0.0);
        }

        @Test
        void 레슨이_없는_유닛이면_0을_반환한다() {
            // given
            long solvedLessonCount = 0L;
            long totalLessonCount = 0L;

            // when
            double result = learningProgressRateService.calculateProgressRate(solvedLessonCount, totalLessonCount);

            // then
            assertThat(result).isEqualTo(0.0);
        }

        @Test
        void 일부_레슨을_풀었으면_진행률을_반환한다() {
            // given
            long solvedLessonCount = 2L;
            long totalLessonCount = 3L;

            // when
            double result = learningProgressRateService.calculateProgressRate(solvedLessonCount, totalLessonCount);

            // then
            assertThat(result).isEqualTo(66.0); // floor(66.66...)
        }

        @Test
        void 모든_레슨을_풀었으면_100을_반환한다() {
            // given
            long solvedLessonCount = 3L;
            long totalLessonCount = 3L;

            // when
            double result = learningProgressRateService.calculateProgressRate(solvedLessonCount, totalLessonCount);

            // then
            assertThat(result).isEqualTo(100.0);
        }
    }

    @Nested
    @DisplayName("행성 정복률을 조회할 때")
    class GetPlanetConquestRate {

        @Test
        void 풀이한_레슨이_없으면_0을_반환한다() {
            // given
            long userId = 1L;

            when(lessonSubmissionRepository.countDistinctLessonByUserId(userId)).thenReturn(0L);

            // when
            int result = learningProgressRateService.getPlanetConquestRate(userId);

            // then
            assertThat(result).isEqualTo(0);
        }

        @Test
        void 일부_레슨을_풀었으면_정복률을_반환한다() {
            // given
            long userId = 1L;

            when(lessonSubmissionRepository.countDistinctLessonByUserId(userId)).thenReturn(1L);
            when(lessonRepository.count()).thenReturn(3L);

            // when
            int result = learningProgressRateService.getPlanetConquestRate(userId);

            // then
            assertThat(result).isEqualTo(33); // round(33.33...) = 33
        }

        @Test
        void 모든_레슨을_풀었으면_100을_반환한다() {
            // given
            long userId = 1L;

            when(lessonSubmissionRepository.countDistinctLessonByUserId(userId)).thenReturn(3L);
            when(lessonRepository.count()).thenReturn(3L);

            // when
            int result = learningProgressRateService.getPlanetConquestRate(userId);

            // then
            assertThat(result).isEqualTo(100);
        }
    }
}
