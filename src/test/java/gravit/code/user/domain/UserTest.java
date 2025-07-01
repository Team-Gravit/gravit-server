package gravit.code.user.domain;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatNoException;

class UserTest {

    @DisplayName("유효한 데이터로 유저를 생성할 수 있다.")
    @Test
    void createUserWithAvailableData(){
        assertThatNoException().isThrownBy(() ->
                User.create("test@inu.ac.kr", "test", "@f9s2w30", "https://example.com/iamge1.jpg"));
    }
}