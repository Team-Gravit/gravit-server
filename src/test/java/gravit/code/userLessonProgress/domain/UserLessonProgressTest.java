package gravit.code.userLessonProgress.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserLessonProgressTest {

    @DisplayName("유효한 데이터로 유저-레슨 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserLessonProgressWithAvailableData(){

        // given
        Long userId = 1L;
        Long lessonId = 1L;

        // when
        UserLessonProgress userLessonProgress = UserLessonProgress.create(userId, lessonId);

        // then
        assertThat(userLessonProgress.getCompletedProblems()).isEqualTo(0L);
        assertThat(userLessonProgress.getUserId()).isEqualTo(userId);
        assertThat(userLessonProgress.getLessonId()).isEqualTo(lessonId);


    }

}