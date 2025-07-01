package gravit.code.league.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatNoException;
import static org.junit.jupiter.api.Assertions.*;

class LeagueTest {

    @DisplayName("유효한 데이터로 리그를 생성할 수 있다.")
    @Test
    void createLeagueWithAvailableData(){
        assertThatNoException().isThrownBy(() ->
                League.create("브론즈", 0, 300, "https://example.com/iamge1.jpg"));
    }

}