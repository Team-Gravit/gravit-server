package gravit.code.lesson.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.internal.LearningIdsDto;
import gravit.code.lesson.dto.response.LessonSummaryResponse;
import gravit.code.lesson.repository.LessonRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.LESSON_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LessonQueryServiceUnitTest {

    @InjectMocks
    private LessonQueryService lessonQueryService;

    @Mock
    private LessonRepository lessonRepository;

    @Nested
    @DisplayName("유닛별 레슨 목록을 조회할 때")
    class GetAllLessonInUnit {

        @Test
        void 성공한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            List<LessonSummaryResponse> expected = List.of(
                    new LessonSummaryResponse(1L, "레슨1", 5, true),
                    new LessonSummaryResponse(2L, "레슨2", 3, false)
            );
            when(lessonRepository.findAllLessonSummaryByUnitId(unitId, userId)).thenReturn(expected);

            // when
            List<LessonSummaryResponse> result = lessonQueryService.getAllLessonInUnit(userId, unitId);

            // then
            assertThat(result).hasSize(2);
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 레슨이_없으면_빈_리스트를_반환한다() {
            // given
            long userId = 1L;
            long unitId = 1L;
            when(lessonRepository.findAllLessonSummaryByUnitId(unitId, userId)).thenReturn(List.of());

            // when
            List<LessonSummaryResponse> result = lessonQueryService.getAllLessonInUnit(userId, unitId);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("레슨 ID로 학습 계층 ID를 조회할 때")
    class GetLearningIdsDtoByLessonId {

        @Test
        void 성공한다() {
            // given
            long lessonId = 1L;
            LearningIdsDto expected = new LearningIdsDto(1L, 2L, lessonId);
            when(lessonRepository.findLearningIdsByLessonId(lessonId)).thenReturn(Optional.of(expected));

            // when
            LearningIdsDto result = lessonQueryService.getLearningIdsByLessonId(lessonId);

            // then
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // given
            long lessonId = 999L;
            when(lessonRepository.findLearningIdsByLessonId(lessonId)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> lessonQueryService.getLearningIdsByLessonId(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(LESSON_NOT_FOUND);
        }
    }
}
