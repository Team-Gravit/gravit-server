package gravit.code.unit.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.UNIT_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UnitQueryServiceUnitTest {

    @InjectMocks
    private UnitQueryService unitQueryService;

    @Mock
    private UnitRepository unitRepository;

    @Nested
    @DisplayName("챕터별 유닛 목록을 조회할 때")
    class GetAllUnitSummaryResponseByChapterId {

        @Test
        void 성공한다() {
            // given
            long chapterId = 1L;
            List<UnitSummaryResponse> expected = List.of(
                    new UnitSummaryResponse(1L, "프로세스", "프로세스 개념"),
                    new UnitSummaryResponse(2L, "스레드", "스레드 개념")
            );
            when(unitRepository.findAllUnitSummaryByChapterId(chapterId)).thenReturn(expected);

            // when
            List<UnitSummaryResponse> result = unitQueryService.getAllUnitSummaryByChapterId(chapterId);

            // then
            assertThat(result).hasSize(2);
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 유닛이_없으면_빈_리스트를_반환한다() {
            // given
            long chapterId = 1L;
            when(unitRepository.findAllUnitSummaryByChapterId(chapterId)).thenReturn(List.of());

            // when
            List<UnitSummaryResponse> result = unitQueryService.getAllUnitSummaryByChapterId(chapterId);

            // then
            assertThat(result).isEmpty();
        }
    }

    @Nested
    @DisplayName("유닛을 단건 조회할 때")
    class GetUnitSummaryByUnitIdResponse {

        @Test
        void 성공한다() {
            // given
            long unitId = 1L;
            UnitSummaryResponse expected = new UnitSummaryResponse(unitId, "프로세스", "프로세스 개념");
            when(unitRepository.findUnitSummaryById(unitId)).thenReturn(Optional.of(expected));

            // when
            UnitSummaryResponse result = unitQueryService.getUnitSummaryByUnitId(unitId);

            // then
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // given
            long unitId = 999L;
            when(unitRepository.findUnitSummaryById(unitId)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> unitQueryService.getUnitSummaryByUnitId(unitId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("레슨 ID로 유닛을 조회할 때")
    class GetUnitSummaryResponseByLessonId {

        @Test
        void 성공한다() {
            // given
            long lessonId = 1L;
            UnitSummaryResponse expected = new UnitSummaryResponse(1L, "프로세스", "프로세스 개념");
            when(unitRepository.findUnitSummaryByLessonId(lessonId)).thenReturn(Optional.of(expected));

            // when
            UnitSummaryResponse result = unitQueryService.getUnitSummaryByLessonId(lessonId);

            // then
            assertThat(result).isEqualTo(expected);
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // given
            long lessonId = 999L;
            when(unitRepository.findUnitSummaryByLessonId(lessonId)).thenReturn(Optional.empty());

            // when & then
            assertThatThrownBy(() -> unitQueryService.getUnitSummaryByLessonId(lessonId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(UNIT_NOT_FOUND);
        }
    }
}
