package gravit.code.domain.league.infrastructure;

import gravit.code.domain.league.domain.League;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LeagueRepository extends JpaRepository<League, Long> {
    Optional<League> findFirstByOrderBySortOrderAsc();
}
