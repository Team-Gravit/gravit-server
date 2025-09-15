package gravit.code.userLeagueHistory.infrastructure;

import gravit.code.season.domain.Season;
import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserLeagueHistoryRepository extends JpaRepository<UserLeagueHistory, Long> {

    @Modifying(clearAutomatically = false, flushAutomatically = true)
    @Query("delete from UserLeagueHistory lh where lh.season = :season")
    int deleteBySeasonId(@Param("season") Season season);

    @Modifying(clearAutomatically = false, flushAutomatically = true)
    @Query("""
           insert into UserLeagueHistory (season, user, finalLeague, finalLp)
           select :season, ul.user, ul.league, ul.lp
           from UserLeague ul
           where ul.season = :season
    """)
    int insertFromCurrent(@Param("season") Season season);


}
