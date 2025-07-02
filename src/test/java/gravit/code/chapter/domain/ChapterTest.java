package gravit.code.chapter.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatNoException;

class ChapterTest {

    @DisplayName("유효한 데이터로 챕터를 생성할 수 있다")
    @Test
    void createChapterWithAvailableData(){
        assertThatNoException().isThrownBy(() ->
                Chapter.create("자료구조", "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다.", 10L));
    }
}