package gravit.code.lesson.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.LessonSubmission;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.lesson.repository.LessonSubmissionRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_SUBMISSION_NOT_FOUND;
import static gravit.code.lesson.fixture.LessonSubmissionFixture.기본_레슨_제출;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LessonSubmissionCommandServiceUnitTest {

    @InjectMocks
    private LessonSubmissionCommandService lessonSubmissionCommandService;

    @Mock
    private LessonSubmissionRepository lessonSubmissionRepository;

    @Mock
    private LessonRepository lessonRepository;

    @Nested
    @DisplayName("레슨 풀이 결과를 저장할 때")
    class SaveLessonSubmission {

        @Test
        void 첫_풀이면_새로_생성한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 120, 80);
            when(lessonRepository.existsById(1L)).thenReturn(true);

            // when
            lessonSubmissionCommandService.saveLessonSubmission(userId, request, true);

            // then
            verify(lessonSubmissionRepository).save(any(LessonSubmission.class));
            verify(lessonSubmissionRepository, never()).findByLessonIdAndUserId(anyLong(), anyLong());
        }

        @Test
        void 재풀이면_기존_기록을_업데이트한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 90, 85);
            LessonSubmission existing = 기본_레슨_제출(1L, userId);

            when(lessonRepository.existsById(1L)).thenReturn(true);
            when(lessonSubmissionRepository.findByLessonIdAndUserId(1L, userId))
                    .thenReturn(Optional.of(existing));

            // when
            lessonSubmissionCommandService.saveLessonSubmission(userId, request, false);

            // then
            verify(lessonSubmissionRepository).findByLessonIdAndUserId(1L, userId);
            verify(lessonSubmissionRepository).save(existing);
        }

        @Test
        void 레슨이_존재하지_않으면_예외를_던진다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(999L, 120, 80);
            when(lessonRepository.existsById(999L)).thenReturn(false);

            // when & then
            assertThatThrownBy(() -> lessonSubmissionCommandService.saveLessonSubmission(userId, request, true))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);
        }

        @Test
        void 재풀이인데_기존_기록이_없으면_예외를_던진다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 120, 80);
            when(lessonRepository.existsById(1L)).thenReturn(true);
            when(lessonSubmissionRepository.findByLessonIdAndUserId(1L, userId))
                    .thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> lessonSubmissionCommandService.saveLessonSubmission(userId, request, false))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_SUBMISSION_NOT_FOUND);
        }
    }
}
