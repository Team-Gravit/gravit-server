//package gravit.code.learning.service;
//
//import gravit.code.global.exception.domain.CustomErrorCode;
//import gravit.code.global.exception.domain.RestApiException;
//import gravit.code.learning.domain.Chapter;
//import gravit.code.learning.domain.ChapterRepository;
//import gravit.code.learning.fixture.ChapterFixture;
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
//class ChapterServiceIntegrationTest {
//
//    @Autowired
//    private ChapterService chapterService;
//
//    @Autowired
//    private ChapterRepository chapterRepository;
//
//    @Nested
//    @DisplayName("챕터 아이디로 챕터를 조회할 때")
//    class FindChapterByChapterId {
//
//        @BeforeEach
//        void setUpTest() {
//            Chapter chapter = ChapterFixture.기본_챕터();
//            chapterRepository.save(chapter);
//        }
//
//        @Test
//        void 챕터_조회에_성공한다() {
//            //given
//            long validChapterId = 1L;
//
//            //when
//            Chapter chapter = chapterService.getChapterById(validChapterId);
//
//            //then
//            assertThat(chapter).isNotNull();
//
//            assertThat(chapter.getId()).isEqualTo(validChapterId);
//            assertThat(chapter.getName()).isEqualTo("챕터이름");
//        }
//
//        @Test
//        void 챕터_아이디가_유효하지_않으면_예외를_반환한다() {
//            //given
//            long invalidChapterId = 999L;
//
//            //when & then
//            assertThatThrownBy(() -> chapterService.getChapterById(invalidChapterId))
//                    .isInstanceOf(RestApiException.class)
//                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
//        }
//    }
//}