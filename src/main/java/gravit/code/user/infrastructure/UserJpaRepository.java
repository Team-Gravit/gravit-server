package gravit.code.user.infrastructure;

import gravit.code.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserJpaRepository extends JpaRepository<User, Long> {
    Optional<User> findByProviderId(String providerId);
    boolean existsByNickname(String nickname);
}
