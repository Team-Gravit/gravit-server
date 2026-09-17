package gravit.code.social.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class RecommendUserQuerySql {

    private static final String MUTUAL_FOLLOW_SUBQUERY = """
            (
                SELECT COUNT(*)
                FROM friends f_my_following
                WHERE f_my_following.follower_id = :userId
                  AND EXISTS (
                      SELECT 1 FROM friends f_follows_cand
                      WHERE f_follows_cand.follower_id = f_my_following.followee_id
                        AND f_follows_cand.followee_id = u.id
                  )
            ) AS mutual_follow_count
            """;

    public static final String SAME_SORT_ORDER_SQL = """
            SELECT u.id AS user_id, u.nickname, u.profile_img_number,
            """ + MUTUAL_FOLLOW_SUBQUERY + """
            FROM users u
            JOIN user_league ul ON ul.user_id = u.id
            JOIN league l ON l.id = ul.league_id
            WHERE l.sort_order = :sortOrder
              AND u.id != :userId
              AND NOT EXISTS (
                  SELECT 1 FROM friends f
                  WHERE f.follower_id = :userId AND f.followee_id = u.id
              )
            ORDER BY RANDOM()
            LIMIT :limit
            """;

    public static final String ADJACENT_SORT_ORDER_SQL = """
            SELECT u.id AS user_id, u.nickname, u.profile_img_number,
            """ + MUTUAL_FOLLOW_SUBQUERY + """
            FROM users u
            JOIN user_league ul ON ul.user_id = u.id
            JOIN league l ON l.id = ul.league_id
            WHERE l.sort_order BETWEEN :minSortOrder AND :maxSortOrder
              AND l.sort_order != :excludeSortOrder
              AND u.id != :userId
              AND NOT EXISTS (
                  SELECT 1 FROM friends f
                  WHERE f.follower_id = :userId AND f.followee_id = u.id
              )
            ORDER BY RANDOM()
            LIMIT :limit
            """;
}
