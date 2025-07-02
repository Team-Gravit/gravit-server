package gravit.code.userProblemProgress.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserProblemProgressTest {

    @DisplayName("유효한 데이터로 유저-문제 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserProblemProgressWithAvailableData(){

        // given
        Long userId = 1L;
        Long problemId = 1L;

        // when
        UserProblemProgress userProblemProgress = UserProblemProgress.create(userId,problemId);

        // then
        assertThat(userProblemProgress.isCorrect()).isFalse();
        assertThat(userProblemProgress.getIncorrectCounts()).isEqualTo(0L);
        assertThat(userProblemProgress.getUserId()).isEqualTo(userId);
        assertThat(userProblemProgress.getProblemId()).isEqualTo(problemId);
    }
}