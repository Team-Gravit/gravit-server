package gravit.code.badge.infrastructure.user;

import gravit.code.badge.domain.Planet;
import gravit.code.badge.domain.user.UserPlanetCompletion;
import org.springframework.data.jpa.repository.JpaRepository;


public interface UserPlanetCompletionRepository extends JpaRepository<UserPlanetCompletion, Long> {
    boolean existsByUserIdAndPlanet(long userId, Planet planet);
    long countByUserId(long userId);
}
