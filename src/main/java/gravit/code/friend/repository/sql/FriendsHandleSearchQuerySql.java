package gravit.code.friend.repository.sql;

import lombok.experimental.UtilityClass;

/**
 * 핸들 검색 쿼리. exact → prefix → contains 순으로 페이지를 채운다.
 *
 * <p>아래 규칙은 성능·정확성에 직결되므로 수정 시 반드시 유지해야 한다.
 * 배경과 실측치는 {@code docs/retrospective-friend-search.md} 참고.
 *
 * <ul>
 *   <li><b>ORDER BY handle USING ~&lt;~</b> — 접두 인덱스 ix_users_handle_like_with_id가
 *       varchar_pattern_ops다. 정렬 연산자를 맞춰야 Sort 노드 없이 LIMIT 건수만 읽고 멈춘다.
 *       기본 ORDER BY handle이면 옵티마이저가 유니크 인덱스를 골라 전체를 훑고,
 *       COLLATE "C"로도 패밀리가 달라 매칭되지 않는다.
 *       handle은 [0-9a-f]뿐이라 ~&lt;~ 순서와 기본 순서가 같아 결과는 불변이다.</li>
 *   <li><b>NOT MATERIALIZED</b> — p가 여러 버킷에서 참조되어 materialize되면 LIKE 패턴이
 *       불투명한 값이 되어 접두 인덱스를 못 탄다.</li>
 *   <li><b>contains의 LIMIT need*3</b> — need=0(앞 버킷이 페이지를 채움)이면 LIMIT 0으로
 *       스캔 자체를 건너뛴다. GREATEST(1, need)로 바꾸면 불필요한 전체 스캔이 생긴다.</li>
 * </ul>
 */
@UtilityClass
public class FriendsHandleSearchQuerySql {

    // --- Search: contains 포함 버전 ---
    public static final String SELECT_USER_WITH_CONTAINS_BY_HANDLE = """
            WITH p AS NOT MATERIALIZED (
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
                  AND handle = p.q
                ORDER BY handle, id
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
                  AND handle LIKE p.q_prefix
                  AND handle <> p.q
                ORDER BY handle USING ~<~, id
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
                  AND handle LIKE p.q_contains
                  AND handle <> p.q
                  AND handle NOT LIKE p.q_prefix
                ORDER BY handle, id
                LIMIT (SELECT need FROM need_contains) * 3
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
            ORDER BY s.w DESC, s.handle ASC, s.id ASC
            LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
            """;

    // --- Search: contains 없는 버전 ---
    public static final String SELECT_USER_NO_CONTAINS_BY_HANDLE = """
            WITH p AS NOT MATERIALIZED (
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
                  AND handle = p.q
                ORDER BY handle, id
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
                  AND handle LIKE p.q_prefix
                  AND handle <> p.q
                ORDER BY handle USING ~<~, id
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
            ORDER BY s.w DESC, s.handle ASC, s.id ASC
            LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
            """;

}
