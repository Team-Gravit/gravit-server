//package gravit.code.domain.unitProgress.service;
//
//import gravit.code.domain.unit.domain.Unit;
//import gravit.code.domain.unit.domain.UnitRepository;
//import gravit.code.domain.unitProgress.domain.UnitProgress;
//import gravit.code.domain.unitProgress.domain.UnitProgressRepository;
//import gravit.code.domain.unitProgress.dto.response.UnitProgressDetailResponse;
//import gravit.code.global.exception.domain.CustomErrorCode;
//import gravit.code.global.exception.domain.RestApiException;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.MockedStatic;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import java.util.List;
//import java.util.Optional;
//
//import static org.assertj.core.api.Assertions.assertThat;
//import static org.assertj.core.api.Assertions.assertThatThrownBy;
//import static org.mockito.Mockito.*;
//
//@ExtendWith(MockitoExtension.class)
//class UnitProgressServiceTest {
//
//    @Mock
//    private UnitProgressRepository unitProgressRepository;
//
//    @Mock
//    private UnitRepository unitRepository;
//
//    @InjectMocks
//    private UnitProgressService unitProgressService;
//
//    @Nested
//    @DisplayName("UnitProgress를 업데이트할 때,")
//    class UpdateUnitProgress{
//
//        @Test
//        @DisplayName("Unit 조회에 실패하면 예외를 반환한다.")
//        void withInvalidUnitId(){
//            //given
//            Long unitId = 1L;
//            Long userId = 1L;
//
//            when(unitRepository.findById(unitId)).thenReturn(Optional.empty());
//
//            //when&then
//            assertThatThrownBy(() -> unitProgressService.updateUnitProgress(any(UnitProgress.class)))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.UNIT_NOT_FOUND);
//        }
//
//        @Test
//        @DisplayName("Unit 조회에 성공하고 UnitProgress 조회에 실패하면 UnitProgress를 생성한 후 업데이트한다.")
//        void withValidUnitIdAndSucceedAtFindUnitProgressThenCreateUnitProgress(){
//            //given
//            Long unitId = 1L;
//            Long userId = 1L;
//
//            Unit targetUnit = Unit.create("유닛", 10L, 1L);
//            UnitProgress unitProgress = mock(UnitProgress.class);
//
//            when(unitRepository.findById(unitId)).thenReturn(Optional.of(targetUnit));
//
//            try(MockedStatic<UnitProgress> mockedStatic = mockStatic(UnitProgress.class)){
//
//                mockedStatic.when(() -> UnitProgress.create(targetUnit.getTotalLessons(), userId, unitId))
//                        .thenReturn(unitProgress);
//
//                //when
//                unitProgressService.updateUnitProgress(any(UnitProgress.class));
//
//                //then
//                mockedStatic.verify(() -> UnitProgress.create(targetUnit.getTotalLessons(), userId, unitId));
//                verify(unitProgress).updateCompletedLessons();
//                verify(unitProgressRepository).save(unitProgress);
//                verify(unitProgress).isComplete();
//
//            }
//        }
//
//        @Test
//        @DisplayName("Unit 조회에 성공하고 UnitProgress 조회도 성공하면 조회한 UnitProgress를 업데이트한다.")
//        void withValidUnitIdAndFailedAtFindUnitProgressThenCreateUnitProgress(){
//            //given
//            Long unitId = 1L;
//            Long userId = 1L;
//
//            Unit targetUnit = Unit.create("유닛", 10L, 1L);
//            UnitProgress unitProgress = mock(UnitProgress.class);
//
//            when(unitRepository.findById(unitId)).thenReturn(Optional.of(targetUnit));
//            when(unitProgressRepository.findByUnitIdAndUserId(unitId, userId)).thenReturn(Optional.of(unitProgress));
//
//            //when
//            unitProgressService.updateUnitProgress(any(UnitProgress.class));
//
//            //then
//            verify(unitProgress).updateCompletedLessons();
//            verify(unitProgressRepository).save(unitProgress);
//            verify(unitProgress).isComplete();
//        }
//    }
//
//    @Nested
//    @DisplayName("모든 유닛(진행도 포함)을 조회할 때,")
//    class GetAllUnitProgress{
//
//        @Test
//        @DisplayName("userId가 유효하지 않으면 예외를 반환한다.")
//        void withInvalidUserId(){
//            //given
//            Long chapterId = 1L;
//            Long userId = 99L;
//
//            when(unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId)).thenReturn(List.of());
//
//            //when&then
//            assertThatThrownBy(() -> unitProgressService.findAllUnitProgress(chapterId, userId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.USER_NOT_FOUND);
//        }
//
//        @Test
//        @DisplayName("userId가 유효하면 정상적으로 반환한다.")
//        void withValidUserId(){
//            //given
//            Long chapterId = 1L;
//            Long userId = 99L;
//
//            List<UnitProgressDetailResponse> unitProgressDetailResponse = mock(List.class);
//
//            when(unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId)).thenReturn(unitProgressDetailResponse);
//
//            //when
//            List<UnitProgressDetailResponse> response = unitProgressService.findAllUnitProgress(chapterId, userId);
//
//            //then
//            assertThat(response).isEqualTo(unitProgressDetailResponse);
//        }
//    }
//}