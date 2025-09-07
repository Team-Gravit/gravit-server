package gravit.code.domain.chapter.domain;

import gravit.code.domain.learning.domain.Chapter;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ChapterTest {

    @DisplayName("유효한 값으로 Chapter를 생성할 수 있다")
    @Test
    void createChapterWithValidValue(){

        // given
        String name = "자료구조";
        String description = "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다.";
        Long totalUnits = 10L;

        // when
        Chapter chapter = Chapter.create(name, description, totalUnits);

        // then
        assertThat(chapter.getName()).isEqualTo(name);
        assertThat(chapter.getDescription()).isEqualTo(description);
        assertThat(chapter.getTotalUnits()).isEqualTo(totalUnits);
    }
}