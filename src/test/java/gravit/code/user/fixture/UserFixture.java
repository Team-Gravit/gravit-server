package gravit.code.user.fixture;

import gravit.code.user.domain.User;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class UserFixture {

    private final UserFixtureBuilder userFixtureBuilder;

    public User 일반_유저(int index) {
        return userFixtureBuilder.user()
                .email("u" + index + "@test.com")
                .providerId("p" + index)
                .nickname("유저" + index)
                .handle("h" + index)
                .create();
    }
}
