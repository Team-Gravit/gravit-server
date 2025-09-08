package gravit.code.domain.unitProgress.service;

import gravit.code.domain.learning.domain.Unit;
import gravit.code.domain.learning.domain.UnitRepository;
import gravit.code.domain.progress.domain.UnitProgress;
import gravit.code.domain.progress.domain.UnitProgressRepository;
import gravit.code.domain.progress.dto.response.UnitProgressDetailResponse;
import gravit.code.domain.progress.service.UnitProgressService;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UnitProgressServiceTest {

    @Mock
    private UnitProgressRepository unitProgressRepository;

    @Mock
    private UnitRepository unitRepository;

    @InjectMocks
    private UnitProgressService unitProgressService;

    @Nested
    @DisplayName("UnitProgress를 업데이트할 때,")
    class UpdateUnitProgress{

        @Test
        @DisplayName("전달받은 UnitProgress의 완료된 레슨 수를 증가시키고 완료 여부를 반환한다.")
        void updateCompletedLessonsAndReturnCompletionStatus(){
            //given
            UnitProgress unitProgress = mock(UnitProgress.class);
            when(unitProgress.isComplete()).thenReturn(true);

            //when
            Boolean result = unitProgressService.updateUnitProgress(unitProgress);

            //then
            verify(unitProgress, times(1)).updateCompletedLessons();
            verify(unitProgress, times(1)).isComplete();
            assertThat(result).isTrue();
        }

        @Test
        @DisplayName("유닛이 완료되지 않았으면 false를 반환한다.")
        void returnFalseWhenUnitNotCompleted(){
            //given
            UnitProgress unitProgress = mock(UnitProgress.class);
            when(unitProgress.isComplete()).thenReturn(false);

            //when
            Boolean result = unitProgressService.updateUnitProgress(unitProgress);

            //then
            verify(unitProgress, times(1)).updateCompletedLessons();
            verify(unitProgress, times(1)).isComplete();
            assertThat(result).isFalse();
        }
    }

    @Nested
    @DisplayName("UnitProgress를 확보할 때,")
    class EnsureUnitProgress{

        @Test
        @DisplayName("Unit 조회에 실패하면 예외를 반환한다.")
        void withInvalidUnitId(){
            //given
            Long unitId = 1L;
            Long userId = 1L;

            when(unitRepository.findById(unitId)).thenReturn(Optional.empty());

            //when&then
            assertThatThrownBy(() -> unitProgressService.ensureUnitProgress(unitId, userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.UNIT_NOT_FOUND);
        }

        @Test
        @DisplayName("기존 UnitProgress가 존재하면 해당 객체를 저장 후 반환한다.")
        void withExistingUnitProgress(){
            //given
            Long unitId = 1L;
            Long userId = 1L;
            Unit targetUnit = mock(Unit.class);
            UnitProgress existingProgress = mock(UnitProgress.class);

            when(unitRepository.findById(unitId)).thenReturn(Optional.of(targetUnit));
            when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId))
                    .thenReturn(Optional.of(existingProgress));
            when(unitProgressRepository.save(existingProgress)).thenReturn(existingProgress);

            //when
            UnitProgress result = unitProgressService.ensureUnitProgress(unitId, userId);

            //then
            assertThat(result).isEqualTo(existingProgress);
            verify(unitProgressRepository).save(existingProgress);
        }

        @Test
        @DisplayName("UnitProgress가 존재하지 않으면 새로 생성한 후 저장하여 반환한다.")
        void withNewUnitProgress(){
            //given
            Long unitId = 1L;
            Long userId = 1L;
            Long totalLessons = 10L;
            Unit targetUnit = mock(Unit.class);
            UnitProgress newProgress = mock(UnitProgress.class);

            when(targetUnit.getTotalLessons()).thenReturn(totalLessons);
            when(unitRepository.findById(unitId)).thenReturn(Optional.of(targetUnit));
            when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId))
                    .thenReturn(Optional.empty());
            when(unitProgressRepository.save(any(UnitProgress.class))).thenReturn(newProgress);

            //when
            UnitProgress result = unitProgressService.ensureUnitProgress(unitId, userId);

            //then
            assertThat(result).isEqualTo(newProgress);
            verify(unitProgressRepository).save(any(UnitProgress.class));
        }
    }

    @Nested
    @DisplayName("모든 유닛(진행도 포함)을 조회할 때,")
    class GetAllUnitProgress{

        @Test
        @DisplayName("userId가 유효하지 않으면 예외를 반환한다.")
        void withInvalidUserId(){
            //given
            Long chapterId = 1L;
            Long userId = 99L;

            when(unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId)).thenReturn(List.of());

            //when&then
            assertThatThrownBy(() -> unitProgressService.findAllUnitProgress(chapterId, userId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
        }

        @Test
        @DisplayName("userId가 유효하면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            Long chapterId = 1L;
            Long userId = 1L;

            List<UnitProgressDetailResponse> unitProgressDetailResponses = List.of(
                    UnitProgressDetailResponse.create(1L, "스택", 4L, 3L),
                    UnitProgressDetailResponse.create(2L, "큐", 3L, 1L)
            );

            when(unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId))
                    .thenReturn(unitProgressDetailResponses);

            //when
            List<UnitProgressDetailResponse> response = unitProgressService.findAllUnitProgress(chapterId, userId);

            //then
            assertThat(response).isEqualTo(unitProgressDetailResponses);
            assertThat(response).hasSize(2);
        }
    }
}