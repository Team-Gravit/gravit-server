package gravit.code.user.domain;

import java.util.Optional;

public interface UserRepository {
    Optional<User> findById(Long id);
    Optional<User> findByProviderId(String providerId);
    void save(User user);

}
