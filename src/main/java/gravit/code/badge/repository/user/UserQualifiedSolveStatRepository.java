package gravit.code.badge.repository.user;

import gravit.code.badge.domain.user.UserQualifiedSolveStat;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserQualifiedSolveStatRepository extends JpaRepository<UserQualifiedSolveStat, Long> {
    Optional<UserQualifiedSolveStat> findByUserId(long userId);
}
