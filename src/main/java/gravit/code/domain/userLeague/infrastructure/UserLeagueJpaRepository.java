package gravit.code.domain.userLeague.infrastructure;

import gravit.code.domain.userLeague.domain.UserLeague;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserLeagueJpaRepository extends JpaRepository<UserLeague,Long> {
    @Query("""
        SELECT l.name
        FROM UserLeague ul
        JOIN League l ON ul.leagueId = l.id
        WHERE ul.userId = :userId
    """)
    String findUserLeagueNameByUserId(@Param("userId") Long userId);
}
