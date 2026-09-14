package gravit.code.userLeague.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class LeagueRankQuerySql {

    public static final String FIND_RANK_IN_LEAGUE_SQL = """
            SELECT 1 + COUNT(*)
            FROM user_league ul
            JOIN users u ON u.id = ul.user_id
            WHERE ul.season_id = :seasonId
              AND ul.league_id = :leagueId
              AND u.deleted_at IS NULL
              AND (
                ul.league_point > :leaguePoint
                OR (ul.league_point = :leaguePoint AND ul.user_id < :userId)
              )
            """;

    public static final String FIND_RANK_PAGE_IN_LEAGUE_SQL = """
            SELECT ul.user_id,
                   ul.league_point
            FROM user_league ul
            JOIN users u ON u.id = ul.user_id
            WHERE ul.season_id = :seasonId
              AND ul.league_id = :leagueId
              AND u.deleted_at IS NULL
            ORDER BY ul.league_point DESC, ul.user_id ASC
            LIMIT :limit OFFSET :offset
            """;
}
