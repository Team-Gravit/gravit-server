package gravit.code.user.fixture;

import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

@TestComponent
@RequiredArgsConstructor
public class UserFixtureBuilder {

    private final UserRepository userRepository;

    private String email = "default@test.com";
    private String providerId = "default_provider";
    private String nickname = "기본유저";
    private String handle = "default_handle";
    private int level = 1;
    private Role role = Role.USER;

    public UserFixtureBuilder user() {
        return new UserFixtureBuilder(userRepository);
    }

    public UserFixtureBuilder email(String email) { this.email = email; return this; }
    public UserFixtureBuilder providerId(String providerId) { this.providerId = providerId; return this; }
    public UserFixtureBuilder nickname(String nickname) { this.nickname = nickname; return this; }
    public UserFixtureBuilder handle(String handle) { this.handle = handle; return this; }
    public UserFixtureBuilder level(int level) { this.level = level; return this; }
    public UserFixtureBuilder role(Role role) { this.role = role; return this; }

    public User create() {
        return userRepository.save(User.create(email, providerId, nickname, handle, level, role));
    }
}
