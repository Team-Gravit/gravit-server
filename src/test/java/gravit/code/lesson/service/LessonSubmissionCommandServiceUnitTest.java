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

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
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
            lessonSubmissionCommandService.saveLessonSubmission(userId, request);

            // then
            verify(lessonSubmissionRepository).save(any(LessonSubmission.class));
        }

        @Test
        void 재풀이면_새_행을_저장한다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(1L, 90, 85);
            when(lessonRepository.existsById(1L)).thenReturn(true);

            // when
            lessonSubmissionCommandService.saveLessonSubmission(userId, request);

            // then
            verify(lessonSubmissionRepository).save(any(LessonSubmission.class));
        }

        @Test
        void 레슨이_존재하지_않으면_예외를_던진다() {
            // given
            long userId = 1L;
            LessonSubmissionSaveRequest request = new LessonSubmissionSaveRequest(999L, 120, 80);
            when(lessonRepository.existsById(999L)).thenReturn(false);

            // when & then
            assertThatThrownBy(() -> lessonSubmissionCommandService.saveLessonSubmission(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);
        }
    }
}
