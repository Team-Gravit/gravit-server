package gravit.code.badge.infrastructure.user;

import gravit.code.badge.domain.Planet;
import gravit.code.badge.domain.user.UserPlanetCompletion;
import org.springframework.data.jpa.repository.JpaRepository;


public interface UserPlanetCompletionRepository extends JpaRepository<UserPlanetCompletion, Long> {
    boolean existsByUserIdAndPlanet(Long userId, Planet planet);
    long countByUserId(Long userId);
}
