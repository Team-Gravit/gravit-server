//package gravit.code.learning.service;
//
//import gravit.code.global.exception.domain.CustomErrorCode;
//import gravit.code.global.exception.domain.RestApiException;
//import gravit.code.learning.domain.*;
//import gravit.code.learning.dto.common.LearningSummary;
//import gravit.code.learning.dto.common.LearningIds;
//import gravit.code.learning.fixture.ChapterFixture;
//import gravit.code.learning.fixture.LessonFixture;
//import gravit.code.learning.fixture.UnitFixture;
//import gravit.code.support.TCSpringBootTest;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//
//import static org.assertj.core.api.Assertions.assertThat;
//import static org.assertj.core.api.Assertions.assertThatThrownBy;
//
//@TCSpringBootTest
//class LessonServiceIntegrationTest {
//
//    @Autowired
//    private LessonService lessonService;
//
//    @Autowired
//    private LessonRepository lessonRepository;
//
//    @Autowired
//    private ChapterRepository chapterRepository;
//
//    @Autowired
//    private UnitRepository unitRepository;
//
//    Chapter chapter;
//    Unit unit;
//    Lesson lesson;
//
//    @BeforeEach
//    void setUp(){
//        chapter = ChapterFixture.기본_챕터();
//        chapterRepository.save(chapter);
//
//        unit = UnitFixture.기본_유닛(chapter.getId());
//        unitRepository.save(unit);
//
//        lesson = LessonFixture.기본_레슨(unit.getId());
//        lessonRepository.save(lesson);
//    }
//
//    @Nested
//    @DisplayName("레슨이 속한 유닛, 챕터의 아이디를 조회할 때")
//    class FindLearningIds{
//
//        @Test
//        void 레슨이_속한_챕터_유닛의_아이디를_성공적으로_조회한다(){
//            //given
//            long validLessonId = lesson.getId();
//
//            //when
//            LearningIds learningIds = lessonService.getLearningIdsByLessonId(validLessonId);
//
//            //then
//            assertThat(learningIds).satisfies(l -> {
//                assertThat(l.chapterId()).isEqualTo(chapter.getId());
//                assertThat(l.unitId()).isEqualTo(unit.getId());
//                assertThat(l.lessonId()).isEqualTo(lesson.getId());
//            });
//        }
//
//        @Test
//        void 레슨_아이디가_유효하지_않으면_예외를_반환한다(){
//            //given
//            long invalidLessonId = 999L;
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
//    class FindLearningAdditionalInfo{
//
//        @Test
//        void 레슨이_속한_챕터_아이디와_레슨_이름을_성공적으로_조회한다(){
//            //given
//            long validLessonId = lesson.getId();
//
//            //when
//            LearningSummary learningAdditionalInfo = lessonService.getLearningAdditionalInfoByLessonId(validLessonId);
//
//            //then
//            assertThat(learningAdditionalInfo).satisfies(l -> {
//                assertThat(l.chapterId()).isEqualTo(chapter.getId());
//                assertThat(l.lessonName()).isEqualTo(lesson.getName());
//            });
//        }
//
//        @Test
//        void 레슨_아이디가_유효하지_않으면_예외를_반환한다(){
//            //given
//            long invalidLessonId = 999L;
//
//            //when & then
//            assertThatThrownBy(() -> lessonService.getLearningAdditionalInfoByLessonId(invalidLessonId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.LESSON_NOT_FOUND);
//        }
//    }
//}