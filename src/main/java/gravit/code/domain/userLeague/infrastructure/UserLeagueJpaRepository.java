package gravit.code.domain.userLeague.infrastructure;

import gravit.code.domain.league.domain.League;
import gravit.code.domain.season.domain.Season;
import gravit.code.domain.userLeague.domain.UserLeague;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserLeagueJpaRepository extends JpaRepository<UserLeague,Long> {
    @Query("""
        SELECT l.name
        FROM UserLeague ul
        JOIN League l ON ul.league.id = l.id
        WHERE ul.user.id = :userId
    """)
    String findUserLeagueNameByUserId(@Param("userId") Long userId);

    boolean existsByUserId(Long userId);

    Optional<UserLeague> findByUserId(Long userId);

    @Modifying(clearAutomatically = false, flushAutomatically = true)
    @Query("""
        update UserLeague ul
        set ul.season   = :nextSeason,
            ul.league   = :startLeague,
            ul.lp       = 0,
            ul.updatedAt = CURRENT_TIMESTAMP
        where ul.season = :currentSeason
    """)
    int resetAllForNextSeason(@Param("currentSeason") Season currentSeason,
                              @Param("nextSeason") Season nextSeason,
                              @Param("startLeague") League startLeague);
}
