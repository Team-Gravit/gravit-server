package gravit.code.userChapterProgress.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserChapterProgressTest {

    @DisplayName("유효한 데이터로 유저-챕터 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserChapterProgressWithAvailableData() {

        // given
        Long userId = 1L;
        Long chapterId = 1L;

        // when
        UserChapterProgress userChapterProgress = UserChapterProgress.create(userId, chapterId);

        // then
        assertThat(userChapterProgress.getCompletedUnits()).isEqualTo(0L);
        assertThat(userChapterProgress.getUserId()).isEqualTo(userId);
        assertThat(userChapterProgress.getChapterId()).isEqualTo(chapterId);

    }
}