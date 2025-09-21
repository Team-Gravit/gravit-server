package gravit.code.userLeagueHistory.infrastructure;

import gravit.code.season.domain.Season;
import gravit.code.userLeagueHistory.domain.UserLeagueHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserLeagueHistoryRepository extends JpaRepository<UserLeagueHistory, Long> {

    @Modifying(clearAutomatically = false, flushAutomatically = true)
    @Query("delete from UserLeagueHistory lh where lh.season = :season")
    int deleteBySeasonId(@Param("season") Season season);

    @Modifying(clearAutomatically = false, flushAutomatically = true)
    @Query(value = """
            INSERT INTO user_league_history (
                season_id, user_id, final_league_id, final_rank, final_lp, created_at, updated_at
            )
            SELECT
                :seasonId AS season_id,
                ul.user_id AS user_id,
                ul.league_id AS final_league_id,
                DENSE_RANK() OVER (
                    PARTITION BY ul.league_id
                    ORDER BY ul.league_point DESC, ul.updated_at ASC, ul.user_id ASC
                ) AS final_rank,
                ul.league_point AS final_lp,
                CURRENT_TIMESTAMP AS created_at,
                CURRENT_TIMESTAMP AS updated_at
            FROM user_league ul
            WHERE ul.season_id = :seasonId
            """, nativeQuery = true)
    int insertFromCurrent(@Param("seasonId") long seasonId);

    boolean existsByUserIdAndSeasonId(long userId, long seasonId);

    Optional<UserLeagueHistory> findByUserIdAndSeasonId(long userId, long seasonId);
}
