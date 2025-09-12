package gravit.code.league.infrastructure;

import gravit.code.league.domain.League;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface LeagueRepository extends JpaRepository<League, Long> {
    Optional<League> findFirstByOrderBySortOrderAsc();

    @Query("""
    select l
        from League l
    where :lp between l.minLp and l.maxLp
    order by l.minLp asc
""")
    Optional<League> findByLpBetween(@Param("lp") int lp);
}
