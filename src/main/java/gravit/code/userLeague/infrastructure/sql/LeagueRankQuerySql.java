package gravit.code.userLeague.infrastructure.sql;

public final class LeagueRankQuerySql {
    private LeagueRankQuerySql() {
    }

    public static final String FIND_RANKING_SQL = """
            WITH r AS MATERIALIZED (
              SELECT ul.user_id,
                     ul.league_point,
                     DENSE_RANK() OVER (
                       PARTITION BY ul.league_id
                       ORDER BY ul.league_point DESC, ul.user_id ASC
                     ) AS rank
              FROM user_league ul
              WHERE ul.league_id = :leagueId
            ),
            cut AS MATERIALIZED (
              SELECT *
              FROM r
              WHERE rank BETWEEN (:offset + 1) AND (:offset + :limit)
              ORDER BY rank, user_id
            )
            SELECT  cut.rank,
                    cut.user_id,
                    cut.league_point AS lp,
                    u.nickname,
                    u.profile_img_number,
                    u.level
            FROM cut
            JOIN users u ON u.id = cut.user_id
            ORDER BY cut.rank, cut.user_id
            """;


    public static final String FIND_RANKING_BY_USER_SQL = """
            SELECT  ranked.rank,
                    ranked.user_id,
                    ranked.league_point AS lp,
                    u.nickname,
                    u.profile_img_number,
                    u.level
            FROM (
                SELECT  ul.user_id,
                        ul.league_point,
                        DENSE_RANK() OVER (
                            PARTITION BY ul.league_id
                            ORDER BY ul.league_point DESC, ul.user_id ASC
                        ) AS rank
                FROM user_league ul
                WHERE ul.league_id = (
                    SELECT league_id FROM user_league WHERE user_id = :userId
                )
            ) ranked
            JOIN users u ON u.id = ranked.user_id
            ORDER BY ranked.rank
            LIMIT :limit OFFSET :offset
            """;
}
