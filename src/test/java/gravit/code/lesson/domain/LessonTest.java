package gravit.code.lesson.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatNoException;

class LessonTest {

    @DisplayName("유효한 데이터로 레슨을 생성할 수 있다")
    @Test
    void createLessonWithAvailableData(){
        assertThatNoException().isThrownBy(() ->
                Lesson.create("의사코드 학습하기", 2L, 1L));
    }
}