package gravit.code.friend.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class FriendsNicknameSearchQuerySql {

    // --- Search: contains 포함 (exact/prefix: lower()+LIKE, contains: ILIKE) ---
    public static final String SELECT_USER_WITH_CONTAINS_BY_NICKNAME = """
        -- NOT MATERIALIZED: p가 여러 버킷에서 참조되어 자동 materialize되면 LIKE 패턴(q_prefix)이
        -- 불투명한 런타임 값이 되어 접두 인덱스(text_pattern_ops)를 못 탄다. 인라인 강제로 인덱스 사용 유지.
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
            -- 정렬키를 인덱스(lower(nickname) text_pattern_ops)와 일치시켜 Index-Only Scan 조기종료 유도.
            -- (ORDER BY nickname(원본)이면 인덱스 정렬과 불일치 → 매칭 전건 heap 읽고 정렬 → Bitmap Heap Scan)
            -- 최종 표시 순서는 바깥 ORDER BY s.nickname이 담당하므로 결과 순서는 불변.
            ORDER BY lower(nickname), id
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
            -- 결정성: 정렬 없이 뽑으면 페이지 넘김 시 후보 집합이 달라져 중복/누락 가능.
            -- 최종 표시 순서(lower(nickname), id)로 뽑아 페이지 간 후보를 고정한다.
            -- (contains는 개선4로 exact+prefix 미충족 시=매칭 적은 경우에만 실행 → 정렬 비용 무시 가능)
            ORDER BY lower(nickname), id
            -- need*3 (0 허용): exact+prefix가 이미 페이지를 채우면 need=0 → LIMIT 0 → contains 스캔 스킵.
            -- (기존 GREATEST(1,need)*3은 불필요할 때도 최소 1건을 찾으려 테이블 전체를 헛스캔했다)
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
        ORDER BY s.w DESC, s.nickname ASC, s.id ASC
        LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
        """;

    // --- Search: contains 없는 버전 (exact/prefix만) ---
    public static final String SELECT_USER_NO_CONTAINS_BY_NICKNAME = """
        -- NOT MATERIALIZED: p가 여러 버킷에서 참조되어 자동 materialize되면 LIKE 패턴(q_prefix)이
        -- 불투명한 런타임 값이 되어 접두 인덱스(text_pattern_ops)를 못 탄다. 인라인 강제로 인덱스 사용 유지.
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
            -- 정렬키를 인덱스(lower(nickname) text_pattern_ops)와 일치시켜 Index-Only Scan 조기종료 유도.
            -- 최종 표시 순서는 바깥 ORDER BY s.nickname이 담당하므로 결과 순서는 불변.
            ORDER BY lower(nickname), id
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
