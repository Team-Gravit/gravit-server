package gravit.code.fcm.service;

import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;

abstract class FcmServiceIntegrationTestBase {

    @Autowired
    protected UserRepository userRepository;

    protected long userId;
    protected long otherUserId;

    @BeforeEach
    void setUpUsers() {
        User user = userRepository.save(User.create("a@test.com", "provider_a", "유저A", "handle_a", 1, Role.USER));
        User other = userRepository.save(User.create("b@test.com", "provider_b", "유저B", "handle_b", 1, Role.USER));
        userId = user.getId();
        otherUserId = other.getId();
    }
}
