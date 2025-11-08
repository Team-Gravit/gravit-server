package gravit.code.userLeague.infrastructure.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class LeagueRankingPagingQuerySql {

    /**
     * leagueId 기반 랭크 페이징 (limit/offset 사용)
     * - offset은 "랭크에서 몇 위를 건너뛸지"
     * - limit은 "가져올 랭크 수(+1로 hasNext 판별)"
     */
    public static final String FIND_RANKING_SQL = """
            WITH ranked AS (
              SELECT ul.user_id,
                     ul.league_point,
                    DENSE_RANK() OVER (
                      PARTITION BY ul.league_id
                       ORDER BY ul.league_point DESC, ul.user_id ASC
                     ) AS rank
              FROM user_league ul
              JOIN users u ON ul.user_id = u.id
              WHERE ul.league_id = :leagueId
                AND u.deleted_at IS NULL
            ),
            cut AS (
              SELECT *
              FROM ranked
              WHERE rank BETWEEN (:offset + 1) AND (:offset + :limit)
            )
            SELECT  cut.rank,
                    cut.user_id,
                    cut.league_point AS lp,
                    u.nickname,
                    u.profile_img_number,
                    u.xp,
                    u.level
            FROM cut
            JOIN users u ON u.id = cut.user_id
            ORDER BY cut.rank, cut.user_id
            """;

    /**
     * userId → 소속 league 찾고, 그 league 기반 랭크 페이징 (limit/offset 사용)
     */
    public static final String FIND_RANKING_BY_USER_SQL = """
            WITH my_league AS (
              SELECT league_id
              FROM user_league
              WHERE user_id = :userId
            ),
            ranked AS (
              SELECT ul.user_id,
                     ul.league_point,
                     DENSE_RANK() OVER (
                       PARTITION BY ul.league_id
                       ORDER BY ul.league_point DESC, ul.user_id ASC
                     ) AS rank
              FROM user_league ul
              JOIN my_league ml ON ml.league_id = ul.league_id
              JOIN users u ON u.id = ul.user_id
              WHERE u.deleted_at IS NULL
            ),
            cut AS (
              SELECT *
              FROM ranked
              WHERE rank BETWEEN (:offset + 1) AND (:offset + :limit)
            )
            SELECT  cut.rank,
                    cut.user_id,
                    cut.league_point AS lp,
                    u.nickname,
                    u.profile_img_number,
                    u.xp,
                    u.level
            FROM cut
            JOIN users u ON u.id = cut.user_id
            ORDER BY cut.rank, cut.user_id
            """;
}
