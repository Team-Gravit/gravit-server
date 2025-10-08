package gravit.code.userLeague.infrastructure.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class MyLeagueRankWithProfileQuerySql {

    /**
     * 유저 단건 랭킹 + 프로필(인덱스 활용)
     * - 나보다 점수가 앞선 사람 수 + 1 로 구함
     **/
    public static final String FIND_MY_RANK_WITH_PROFILE_SQL = """
            WITH me AS (
              SELECT ul.user_id, ul.league_id, ul.league_point
              FROM user_league ul
              WHERE ul.user_id = :userId
            )
            SELECT
            me.league_id AS league_id,
            l.name AS league_name,
            l.max_lp AS max_lp,
              (
                SELECT 1 + COUNT(*)
                FROM user_league ul2
                JOIN me ON me.league_id = ul2.league_id
                WHERE (ul2.league_point > me.league_point)
                   OR (ul2.league_point = me.league_point AND ul2.user_id < me.user_id)
              ) AS rank,
              me.user_id,
              me.league_point AS lp,
              u.nickname,
              u.profile_img_number,
              u.xp,
              u.level
            FROM me
            JOIN users u ON u.id = me.user_id AND u.deleted_at IS NULL
            JOIN league l ON l.id = me.league_id
            """;
}
