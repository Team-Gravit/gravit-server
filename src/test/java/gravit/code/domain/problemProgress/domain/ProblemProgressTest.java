package gravit.code.domain.problemProgress.domain;

import gravit.code.domain.progress.domain.ProblemProgress;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ProblemProgressTest {

    @DisplayName("유효한 데이터로 유저-문제 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserProblemProgressWithAvailableData(){

        // given
        Boolean isCorrect = false;
        Long inCorrectCounts = 1L;
        Long userId = 1L;
        Long problemId = 1L;

        // when
        ProblemProgress problemProgress = ProblemProgress.create(isCorrect, inCorrectCounts, userId, problemId);

        // then
        assertThat(problemProgress.isCorrect()).isFalse();
        assertThat(problemProgress.getIncorrectCounts()).isEqualTo(1L);
        assertThat(problemProgress.getUserId()).isEqualTo(userId);
        assertThat(problemProgress.getProblemId()).isEqualTo(problemId);
    }
}