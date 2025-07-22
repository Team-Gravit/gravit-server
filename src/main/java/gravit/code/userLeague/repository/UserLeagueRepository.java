package gravit.code.userLeague.repository;

import gravit.code.userLeague.domain.UserLeague;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserLeagueRepository extends JpaRepository<UserLeague,Long> {

    @Query("""
        SELECT l.name
        FROM UserLeague ul
        JOIN League l ON ul.leagueId = l.id
        WHERE ul.userId = :userId
    """)
    String findUserLeagueNameByUserId(@Param("userId") Long userId);
}
