package gravit.code.domain.league.domain;

import gravit.code.domain.league.domain.League;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class LeagueTest {

    @DisplayName("유효한 데이터로 리그를 생성할 수 있다")
    @Test
    void createLeagueWithAvailableData(){

        // given
        String name = "브론즈";
        Integer maxXp = 0;
        Integer minYp = 0;

        // when
        League league = League.create(name, maxXp, minYp, 1);

        // then
        assertThat(league.getName()).isEqualTo(name);
    }

}