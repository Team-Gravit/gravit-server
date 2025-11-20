//package gravit.code.learning.service;
//
//import gravit.code.global.exception.domain.CustomErrorCode;
//import gravit.code.global.exception.domain.RestApiException;
//import gravit.code.learning.domain.LessonRepository;
//import gravit.code.learning.dto.common.LearningAdditionalInfo;
//import gravit.code.learning.dto.common.LearningIds;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import java.util.Optional;
//
//import static org.assertj.core.api.Assertions.assertThatThrownBy;
//import static org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//@ExtendWith(MockitoExtension.class)
//class LessonServiceUnitTest {
//
//    @Mock
//    private LessonRepository lessonRepository;
//
//    @InjectMocks
//    private LessonService lessonService;
//
//    @Nested
//    @DisplayName("레슨이 속한 유닛, 챕터의 아이디를 조회할 때")
//    class FindLearningIds{
//        @Test
//        void 레슨이_속한_챕터_유닛의_아이디를_성공적으로_조회한다(){
//            //given
//            long chapterId = 1L;
//            long unitId = 1L;
//            long validLessonId = 1L;
//
//            LearningIds learningIds = LearningIds.of(chapterId, unitId, validLessonId);
//
//            when(lessonRepository.findLearningIdsByLessonId(validLessonId))
//                    .thenReturn(Optional.ofNullable(learningIds));
//
//            //when
//            lessonService.getLearningIdsByLessonId(validLessonId);
//
//            //then
//            verify(lessonRepository).findLearningIdsByLessonId(validLessonId);
//        }
//
//        @Test
//        void 레슨_아이디가_유효하지_않으면_예외를_반환한다(){
//            //given
//            long invalidLessonId = 999L;
//
//            when(lessonRepository.findLearningIdsByLessonId(invalidLessonId))
//                    .thenReturn(Optional.empty());
//
//            //when & then
//            assertThatThrownBy(() -> lessonService.getLearningIdsByLessonId(invalidLessonId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
//        }
//    }
//
//    @Nested
//    @DisplayName("레슨이 속한 챕터 아이디와 레슨 이름을 조회할 때")
//    class FindLearningAdditionalInfo {
//
//        @Test
//        void 레슨이_속한_챕터_아이디와_레슨_이름을_성공적으로_조회한다(){
//            //given
//            long chapterId = 1L;
//            long validLessonId = 1L;
//            String lessonName = "레슨이름";
//
//            LearningAdditionalInfo learningAdditionalInfo = LearningAdditionalInfo.of(chapterId, lessonName);
//
//            when(lessonRepository.findLearningAdditionalInfoByLessonId(validLessonId))
//                    .thenReturn(Optional.ofNullable(learningAdditionalInfo));
//
//            //when
//            lessonService.getLearningAdditionalInfoByLessonId(validLessonId);
//
//            //then
//            verify(lessonRepository).findLearningAdditionalInfoByLessonId(validLessonId);
//        }
//
//        @Test
//        void 레슨_아이디가_유효하지_않으면_예외를_반환한다(){
//            //given
//            long inValidLessonId = 999L;
//
//            when(lessonRepository.findLearningAdditionalInfoByLessonId(inValidLessonId))
//                    .thenReturn(Optional.empty());
//
//            //when & then
//            assertThatThrownBy(() -> lessonService.getLearningAdditionalInfoByLessonId(inValidLessonId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
//        }
//    }
//}