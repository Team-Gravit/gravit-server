package gravit.code.domain.lesson.domain;

import gravit.code.domain.learning.domain.Lesson;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class LessonTest {

    @Test
    @DisplayName("유효한 데이터로 레슨을 생성할 수 있다")
    void createLessonWithAvailableData(){

        // given
        String name = "의사코드 학습하기";
        Long totalProblems = 2L;
        Long unitId = 1L;

        // when
        Lesson lesson = Lesson.create(name, totalProblems, unitId);

        // then
        assertThat(lesson.getName()).isEqualTo(name);
        assertThat(lesson.getTotalProblems()).isEqualTo(totalProblems);
        assertThat(lesson.getUnitId()).isEqualTo(unitId);
    }
}