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
        String leagueImgUrl = "https://example.com/league1.jpg";

        // when
        League league = League.create(name, maxXp, minYp, leagueImgUrl);

        // then
        assertThat(league.getName()).isEqualTo(name);
        assertThat(league.getMaxXp()).isEqualTo(maxXp);
        assertThat(league.getMinXp()).isEqualTo(minYp);
        assertThat(league.getLeagueImgUrl()).isEqualTo(leagueImgUrl);
    }

}