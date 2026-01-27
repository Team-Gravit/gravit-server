package gravit.code.badge.repository.user;

import gravit.code.badge.domain.user.UserMissionStat;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserMissionStatRepository extends JpaRepository<UserMissionStat, Long> {
    Optional<UserMissionStat> findByUserId(long userId);
}
