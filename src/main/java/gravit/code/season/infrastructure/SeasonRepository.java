package gravit.code.season.infrastructure;

import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface SeasonRepository extends JpaRepository<Season, Long> {
    Optional<Season> findByStatus(SeasonStatus seasonStatus);
    boolean existsByStatus(SeasonStatus seasonStatus);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select s from Season s
            where s.status = 'ACTIVE' and s.endsAt <= :now
    """)
    Optional<Season> findCloseableActiveByNowForUpdate(@Param("now") LocalDateTime now);

    @Query("""
            select s from Season s
            where s.status = 'PREP' and s.startsAt = :startsAt
    """)
    Optional<Season> findPrepByStartingAt(@Param("startsAt") LocalDateTime startsAt);

    Optional<Season> findBySeasonKey(String seasonKey);
}
