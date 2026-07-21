package gravit.code.friend.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class FriendsNicknameSearchQuerySql {

    // --- Search: contains 포함 (exact/prefix: lower()+LIKE, contains: ILIKE) ---
    public static final String SELECT_USER_WITH_CONTAINS_BY_NICKNAME = """
        -- NOT MATERIALIZED: p가 여러 버킷에서 참조되어 자동 materialize되면 LIKE 패턴(q_prefix)이
        -- 불투명한 런타임 값이 되어 접두 인덱스(ix_users_nickname_lower_cover)를 못 탄다. 인라인 강제로 인덱스 사용 유지.
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
            -- COLLATE "C" 필수: 인덱스가 C 콜레이션이라 동등 비교의 콜레이션이 다르면 Index Cond로
            -- 승격되지 못하고 Seq Scan으로 떨어진다. (LIKE와 달리 = 는 플래너가 보정해주지 않는다)
              AND lower(nickname) COLLATE "C" = p.q
            -- exact 버킷도 표시 정렬키와 동일하게 맞춘다(lower가 모두 같아 실질 정렬은 id).
            ORDER BY lower(nickname) COLLATE "C", id
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
            -- 정렬키를 인덱스(ix_users_nickname_lower_cover = lower(nickname) COLLATE "C")와 정확히 일치시킨다.
            -- 표현식(lower)과 콜레이션(C)이 모두 맞아야 인덱스 정렬을 그대로 써서 LIMIT 건수만 읽고 멈춘다.
            -- 둘 중 하나라도 어긋나면 Sort 노드가 붙어 매칭 전건을 읽는다.
            -- 최종 표시 순서는 바깥 ORDER BY s.nickname이 담당하므로 결과 순서는 불변.
            ORDER BY lower(nickname) COLLATE "C", id
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
            -- 최종 표시 순서(lower(nickname) COLLATE "C", id)로 뽑아 페이지 간 후보를 고정한다.
            -- (contains는 개선4로 exact+prefix 미충족 시=매칭 적은 경우에만 실행 → 정렬 비용 무시 가능)
            ORDER BY lower(nickname) COLLATE "C", id
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
        -- 표시 순서를 후보 선정 정렬키(lower(nickname) COLLATE "C")와 동일하게 맞춘다.
        -- 각 버킷이 C 순서로 LIMIT을 잘라 후보를 고르므로, 표시를 다른 콜레이션으로 하면
        -- "표시 순서상 앞서지만 C 순서로는 뒤라 후보에 못 든" 행이 통째로 누락된다.
        -- (실측: 한글/ASCII가 섞인 '김%' 검색에서 1페이지 20건이 표시순 정답과 0건 일치)
        -- 순수 한글 구간에서 C 순서는 가나다 순과 일치하고, ASCII가 한글보다 앞서는 차이만 남는다.
        ORDER BY s.w DESC, lower(s.nickname) COLLATE "C" ASC, s.id ASC
        LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
        """;

    // --- Search: contains 없는 버전 (exact/prefix만) ---
    public static final String SELECT_USER_NO_CONTAINS_BY_NICKNAME = """
        -- NOT MATERIALIZED: p가 여러 버킷에서 참조되어 자동 materialize되면 LIKE 패턴(q_prefix)이
        -- 불투명한 런타임 값이 되어 접두 인덱스(ix_users_nickname_lower_cover)를 못 탄다. 인라인 강제로 인덱스 사용 유지.
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
            -- COLLATE "C" 필수: 인덱스가 C 콜레이션이라 동등 비교의 콜레이션이 다르면 Index Cond로
            -- 승격되지 못하고 Seq Scan으로 떨어진다. (LIKE와 달리 = 는 플래너가 보정해주지 않는다)
              AND lower(nickname) COLLATE "C" = p.q
            -- exact 버킷도 표시 정렬키와 동일하게 맞춘다(lower가 모두 같아 실질 정렬은 id).
            ORDER BY lower(nickname) COLLATE "C", id
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
            -- 정렬키를 인덱스(ix_users_nickname_lower_cover = lower(nickname) COLLATE "C")와 정확히 일치시켜
            -- 인덱스 정렬을 그대로 쓰고 LIMIT 건수만 읽고 멈춘다.
            -- 최종 표시 순서는 바깥 ORDER BY s.nickname이 담당하므로 결과 순서는 불변.
            ORDER BY lower(nickname) COLLATE "C", id
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
        -- 표시 순서를 후보 선정 정렬키(lower(nickname) COLLATE "C")와 동일하게 맞춘다.
        -- 각 버킷이 C 순서로 LIMIT을 잘라 후보를 고르므로, 표시를 다른 콜레이션으로 하면
        -- "표시 순서상 앞서지만 C 순서로는 뒤라 후보에 못 든" 행이 통째로 누락된다.
        -- (실측: 한글/ASCII가 섞인 '김%' 검색에서 1페이지 20건이 표시순 정답과 0건 일치)
        -- 순수 한글 구간에서 C 순서는 가나다 순과 일치하고, ASCII가 한글보다 앞서는 차이만 남는다.
        ORDER BY s.w DESC, lower(s.nickname) COLLATE "C" ASC, s.id ASC
        LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
        """;
}
