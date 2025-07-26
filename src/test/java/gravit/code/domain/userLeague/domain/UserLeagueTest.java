package gravit.code.domain.userLeague.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class UserLeagueTest {

    @DisplayName("유효한 데이터로 유저-리그 중간 테이블 앤티티를 생성할 수 있다")
    @Test
    void createUserLeagueWithAvailableData() {

        // given
        Integer level = 1;
        Integer xp = 0;
        Long userId = 1L;
        Long leagueId = 1L;

        // when
        UserLeague userLeague = UserLeague.create(userId, leagueId);

        // then
        assertThat(userLeague.getUserId()).isEqualTo(userId);
        assertThat(userLeague.getLeagueId()).isEqualTo(leagueId);

    }

}