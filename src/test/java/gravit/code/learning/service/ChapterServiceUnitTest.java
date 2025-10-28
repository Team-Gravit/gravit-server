package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import gravit.code.learning.fixture.ChapterFixture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChapterServiceUnitTest {

    @InjectMocks
    private ChapterService chapterService;

    @Mock
    private ChapterRepository chapterRepository;

    @Nested
    @DisplayName("챕터 아이디로 챕터를 조회할 때")
    class FindChapterByChapterId{

        Chapter chapter;

        @BeforeEach
        void setUp() {
            chapter = ChapterFixture.기본_챕터();
        }

        @Test
        void 챕터_조회에_성공한다(){
            //given
            long validChapterId = 1L;
            when(chapterRepository.findById(validChapterId)).thenReturn(Optional.ofNullable(chapter));

            //when
            Chapter chapter = chapterService.getChapterById(validChapterId);

            //then
            verify(chapterRepository).findById(validChapterId);

            assertThat(chapter).isNotNull();
        }

        @Test
        void 챕터_아이디가_유효하지_않으면_예외를_반환한다(){
            //given
            long invalidChapterId = 999L;
            when(chapterRepository.findById(invalidChapterId)).thenReturn(Optional.empty());

            //when & then
            assertThatThrownBy(() -> chapterService.getChapterById(invalidChapterId))
                    .isInstanceOf(RestApiException.class)
                    .hasFieldOrPropertyWithValue("errorCode", CustomErrorCode.CHAPTER_NOT_FOUND);
        }
    }
}