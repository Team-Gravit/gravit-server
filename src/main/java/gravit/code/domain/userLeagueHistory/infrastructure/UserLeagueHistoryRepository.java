package gravit.code.domain.userLeagueHistory.infrastructure;

import gravit.code.domain.season.domain.Season;
import gravit.code.domain.userLeagueHistory.domain.UserLeagueHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserLeagueHistoryRepository extends JpaRepository<UserLeagueHistory, Long> {

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("delete from UserLeagueHistory lh where lh.season = :season")
    int deleteBySeasonId(@Param("season") Season season);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
           insert into UserLeagueHistory (season, user, finalLeague, finalLp)
           select :season, ul.user, ul.league, ul.lp, CURRENT_TIMESTAMP
           from UserLeague ul
           where ul.season = :season
    """)
    int insertFromCurrent(@Param("season") Season season);


}
