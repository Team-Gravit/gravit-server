package gravit.code.domain.league.infrastructure;

import gravit.code.domain.league.domain.League;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LeagueRepository extends JpaRepository<League, Long> {

}
