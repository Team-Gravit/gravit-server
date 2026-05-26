package gravit.code.userLeague.repository;

import gravit.code.userLeague.domain.UserLeague;
import gravit.code.userLeague.repository.custom.LeagueRankingQueryRepository;
import gravit.code.userLeague.repository.custom.MyLeagueProfileQueryRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserLeagueRepository extends JpaRepository<UserLeague,Long>, LeagueRankingQueryRepository, MyLeagueProfileQueryRepository {

    @Query(value = """
            SELECT ranked.rank_in_league
            FROM (
                SELECT ul.user_id,
                       DENSE_RANK() OVER (
                           PARTITION BY ul.league_id
                           ORDER BY ul.league_point DESC, ul.updated_at ASC, ul.user_id ASC
                       ) AS rank_in_league
                FROM user_league ul
                WHERE ul.season_id = :seasonId
            ) ranked
            WHERE ranked.user_id = :userId
            """, nativeQuery = true)
    Optional<Integer> findCurrentRankByUserId(
            @Param("userId") long userId,
            @Param("seasonId") long seasonId
    );
    @Query("""
        SELECT l.name
        FROM UserLeague ul
        JOIN League l ON ul.league.id = l.id
        WHERE ul.user.id = :userId
    """)
    Optional<String> findUserLeagueNameByUserId(@Param("userId") Long userId);

    @Query("SELECT ul.league.sortOrder FROM UserLeague ul WHERE ul.user.id = :userId")
    Optional<Integer> findLeagueSortOrderByUserId(@Param("userId") Long userId);

    boolean existsByUserId(Long userId);

    Optional<UserLeague> findByUserId(Long userId);

    Optional<UserLeague> findByUserIdAndSeasonId(Long userId, Long seasonId);

    @Modifying(clearAutomatically = false, flushAutomatically = true)
    @Query(value = """
            UPDATE user_league ul
            SET season_id    = :nextSeasonId,
                league_id    = (SELECT l2.id FROM league l2
                                WHERE l2.sort_order = CASE l_prev.sort_order
                                    WHEN 1  THEN 1  WHEN 2  THEN 1  WHEN 3  THEN 1
                                    WHEN 4  THEN 2  WHEN 5  THEN 2  WHEN 6  THEN 3
                                    WHEN 7  THEN 4  WHEN 8  THEN 5  WHEN 9  THEN 6
                                    WHEN 10 THEN 7  WHEN 11 THEN 8  WHEN 12 THEN 9
                                    WHEN 13 THEN 10 WHEN 14 THEN 11 WHEN 15 THEN 12
                                END),
                league_point = CASE l_prev.sort_order
                    WHEN 1  THEN 0    WHEN 2  THEN 0    WHEN 3  THEN 50
                    WHEN 4  THEN 101  WHEN 5  THEN 150  WHEN 6  THEN 201
                    WHEN 7  THEN 321  WHEN 8  THEN 461  WHEN 9  THEN 621
                    WHEN 10 THEN 801  WHEN 11 THEN 1001 WHEN 12 THEN 1221
                    WHEN 13 THEN 1461 WHEN 14 THEN 1721 WHEN 15 THEN 2001
                END,
                updated_at   = NOW()
            FROM user_league_history ulh
            JOIN league l_prev ON ulh.final_league_id = l_prev.id
            WHERE ul.season_id  = :currentSeasonId
              AND ulh.season_id = :currentSeasonId
              AND ulh.user_id   = ul.user_id
            """, nativeQuery = true)
    int softResetForNextSeason(
            @Param("currentSeasonId") long currentSeasonId,
            @Param("nextSeasonId") long nextSeasonId
    );
}
