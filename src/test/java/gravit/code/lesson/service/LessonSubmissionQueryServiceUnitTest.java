package gravit.code.lesson.service;

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
class LessonSubmissionQueryServiceUnitTest {

    @InjectMocks
    private LessonSubmissionQueryService lessonSubmissionQueryService;

    @Mock
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Nested
    @DisplayName("레슨 제출 횟수를 조회할 때")
    class GetLessonSubmissionCount {

        @Test
        void 제출_기록이_있으면_횟수를_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            when(lessonSubmissionRepository.countLessonSubmissionByLessonIdAndUserId(lessonId, userId))
                    .thenReturn(3);

            // when
            int result = lessonSubmissionQueryService.getLessonSubmissionTryCount(userId, lessonId);

            // then
            assertThat(result).isEqualTo(3);
        }

        @Test
        void 제출_기록이_없으면_0을_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            when(lessonSubmissionRepository.countLessonSubmissionByLessonIdAndUserId(lessonId, userId))
                    .thenReturn(0);

            // when
            int result = lessonSubmissionQueryService.getLessonSubmissionTryCount(userId, lessonId);

            // then
            assertThat(result).isZero();
        }
    }

    @Nested
    @DisplayName("첫 번째 레슨 제출인지 확인할 때")
    class CheckFirstLessonSubmission {

        @Test
        void 첫_제출이면_true를_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            when(lessonSubmissionRepository.existsByLessonIdAndUserId(lessonId, userId))
                    .thenReturn(false);

            // when
            boolean result = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonId);

            // then
            assertThat(result).isTrue();
        }

        @Test
        void 이미_제출한_적이_있으면_false를_반환한다() {
            // given
            long userId = 1L;
            long lessonId = 1L;
            when(lessonSubmissionRepository.existsByLessonIdAndUserId(lessonId, userId))
                    .thenReturn(true);

            // when
            boolean result = lessonSubmissionQueryService.checkFirstLessonSubmission(userId, lessonId);

            // then
            assertThat(result).isFalse();
        }
    }
}
