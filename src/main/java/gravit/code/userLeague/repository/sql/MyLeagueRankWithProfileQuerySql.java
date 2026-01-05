package gravit.code.userLeague.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class MyLeagueRankWithProfileQuerySql {

    /**
     * 유저 단건 랭킹 + 프로필(인덱스 활용)
     * - 나보다 점수가 앞선 사람 수 + 1 로 구함
     **/
    public static final String FIND_MY_RANK_WITH_PROFILE_SQL = """
            WITH me AS (
              SELECT
                ul.user_id,
                ul.league_id,
                ul.league_point,
                u.nickname,
                u.profile_img_number,
                u.xp,
                u.level
              FROM user_league ul
              JOIN users u ON u.id = ul.user_id
              WHERE ul.user_id = :userId
                AND u.deleted_at IS NULL
            )
            SELECT
              me.league_id   AS league_id,
              l.name         AS league_name,
              l.max_lp       AS max_lp,
              (
                SELECT 1 + COUNT(*)
                FROM user_league ul2
                WHERE ul2.league_id = me.league_id
                  AND (
                    ul2.league_point > me.league_point
                    OR (ul2.league_point = me.league_point AND ul2.user_id < me.user_id)
                  )
                  AND EXISTS (
                    SELECT 1 FROM users u2
                    WHERE u2.id = ul2.user_id
                      AND u2.deleted_at IS NULL
                  )
              ) AS rank,
              me.user_id,
              me.league_point      AS lp,
              me.nickname,
              me.profile_img_number,
              me.xp,
              me.level
            FROM me
            JOIN league l ON l.id = me.league_id;
            """;
}
