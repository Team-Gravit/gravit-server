package gravit.code.domain.season.infrastructure;

import gravit.code.domain.season.domain.Season;
import gravit.code.domain.season.domain.SeasonStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SeasonRepository extends JpaRepository<Season, Long> {
    Optional<Season> findByStatus(SeasonStatus seasonStatus);
    boolean existsByStatus(SeasonStatus seasonStatus);
}
