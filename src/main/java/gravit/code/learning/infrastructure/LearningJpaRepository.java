package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Learning;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LearningJpaRepository extends JpaRepository<Learning,Long> {
    Optional<Learning> findByUserId(Long userId);

    List<Learning> findAllByTodaySolved(Boolean todaySolved);
}
