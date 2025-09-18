package gravit.code.progress.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class LessonProgressTest {

    @DisplayName("유효한 데이터로 유저-레슨 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserLessonProgressWithAvailableData(){

        // given
        long userId = 1L;
        long lessonId = 1L;
        Boolean isCompleted = false;

        // when
        LessonProgress lessonProgress = LessonProgress.create(userId, lessonId);

        // then
        assertThat(lessonProgress.getUserId()).isEqualTo(userId);
        assertThat(lessonProgress.getLessonId()).isEqualTo(lessonId);
    }

}