package gravit.code.friend.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class FriendsNicknameSearchQuerySql {

    // --- Search: contains 포함 (exact/prefix: lower()+LIKE, contains: ILIKE) ---
    public static final String SELECT_USER_WITH_CONTAINS_BY_NICKNAME = """
        WITH p AS (
          SELECT :me::bigint AS me,
                 :q::text AS q,
                 :q_prefix::text AS q_prefix,
                 :q_contains::text AS q_contains,
                 :limit::int AS lim,
                 :offset::int AS off
        ),
        exact AS MATERIALIZED (
          SELECT u.* FROM p
          CROSS JOIN LATERAL (
            SELECT id, profile_img_number, nickname, handle
            FROM users
            WHERE id <> p.me
              AND deleted_at IS NULL
              AND lower(nickname) = p.q
            ORDER BY nickname, id
            LIMIT p.lim + p.off
          ) u
        ),
        prefix_all AS MATERIALIZED (
          SELECT u.* FROM p
          CROSS JOIN LATERAL (
            SELECT id, profile_img_number, nickname, handle
            FROM users
            WHERE id <> p.me
              AND deleted_at IS NULL
              AND lower(nickname) LIKE p.q_prefix
              AND lower(nickname) <> p.q
            ORDER BY nickname, id
            LIMIT p.lim + p.off
          ) u
        ),
        cnt_exact AS (SELECT count(*) c FROM exact),
        need_prefix AS (
          SELECT GREATEST(0, (SELECT lim+off FROM p) - (SELECT c FROM cnt_exact)) AS need
        ),
        prefix AS MATERIALIZED (
          SELECT * FROM prefix_all
          LIMIT (SELECT need FROM need_prefix)
        ),
        cnt_prefix AS (SELECT count(*) c FROM prefix),
        need_contains AS (
          SELECT GREATEST(0, (SELECT lim+off FROM p) - (SELECT c FROM cnt_exact) - (SELECT c FROM cnt_prefix)) AS need
        ),
        contains_ids AS MATERIALIZED (
          SELECT u.id
          FROM p
          CROSS JOIN LATERAL (
            SELECT id
            FROM users
            WHERE id <> p.me
              AND deleted_at IS NULL
              AND nickname ILIKE p.q_contains
              AND lower(nickname) <> p.q
              AND lower(nickname) NOT LIKE p.q_prefix
            LIMIT GREATEST(1, (SELECT need FROM need_contains)) * 3
          ) u
        ),
        contains AS MATERIALIZED (
          SELECT u.id, u.profile_img_number, u.nickname, u.handle
          FROM users u
          JOIN contains_ids c ON c.id = u.id
          WHERE u.deleted_at IS NULL
        ),
        unioned AS (
          SELECT id, profile_img_number, nickname, handle, 3 AS w FROM exact
          UNION ALL
          SELECT id, profile_img_number, nickname, handle, 2 AS w FROM prefix
          UNION ALL
          SELECT id, profile_img_number, nickname, handle, 1 AS w FROM contains
        )
        SELECT
          s.id AS user_id,
          s.profile_img_number,
          s.nickname,
          concat('@', s.handle) AS handle,
          (f.followee_id IS NOT NULL) AS is_following,
          s.w
        FROM unioned s
        LEFT JOIN friends f
          ON f.follower_id = (SELECT me FROM p)
         AND f.followee_id = s.id
        ORDER BY s.w DESC, s.nickname ASC, s.id ASC
        LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
        """;

    // --- Search: contains 없는 버전 (exact/prefix만) ---
    public static final String SELECT_USER_NO_CONTAINS_BY_NICKNAME = """
        WITH p AS (
          SELECT :me::bigint AS me,
                 :q::text AS q,
                 :q_prefix::text AS q_prefix,
                 :limit::int AS lim,
                 :offset::int AS off
        ),
        exact AS MATERIALIZED (
          SELECT u.* FROM p
          CROSS JOIN LATERAL (
            SELECT id, profile_img_number, nickname, handle
            FROM users
            WHERE id <> p.me
              AND deleted_at IS NULL
              AND lower(nickname) = p.q
            ORDER BY nickname, id
            LIMIT p.lim + p.off
          ) u
        ),
        prefix_all AS MATERIALIZED (
          SELECT u.* FROM p
          CROSS JOIN LATERAL (
            SELECT id, profile_img_number, nickname, handle
            FROM users
            WHERE id <> p.me
              AND deleted_at IS NULL
              AND lower(nickname) LIKE p.q_prefix
              AND lower(nickname) <> p.q
            ORDER BY nickname, id
            LIMIT p.lim + p.off
          ) u
        ),
        cnt_exact AS (SELECT count(*) c FROM exact),
        need_prefix AS (
          SELECT GREATEST(0, (SELECT lim+off FROM p) - (SELECT c FROM cnt_exact)) AS need
        ),
        prefix AS MATERIALIZED (
          SELECT * FROM prefix_all
          LIMIT (SELECT need FROM need_prefix)
        ),
        unioned AS (
          SELECT id, profile_img_number, nickname, handle, 3 AS w FROM exact
          UNION ALL
          SELECT id, profile_img_number, nickname, handle, 2 AS w FROM prefix
        )
        SELECT
          s.id AS user_id,
          s.profile_img_number,
          s.nickname,
          concat('@', s.handle) AS handle,
          (f.followee_id IS NOT NULL) AS is_following,
          s.w
        FROM unioned s
        LEFT JOIN friends f
          ON f.follower_id = (SELECT me FROM p)
         AND f.followee_id = s.id
        ORDER BY s.w DESC, s.nickname ASC, s.id ASC
        LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
        """;
}
