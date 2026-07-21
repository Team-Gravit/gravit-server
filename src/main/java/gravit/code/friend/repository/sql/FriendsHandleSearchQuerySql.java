package gravit.code.friend.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class FriendsHandleSearchQuerySql {

    // --- Search: contains 포함 버전 ---
    public static final String SELECT_USER_WITH_CONTAINS_BY_HANDLE = """
            -- NOT MATERIALIZED: p가 여러 버킷에서 참조되어 자동 materialize되면 LIKE 패턴(q_prefix)이
            -- 불투명한 런타임 값이 되어 접두 인덱스(varchar_pattern_ops)를 못 탄다. 인라인 강제로 인덱스 사용 유지.
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
                -- USING ~<~: 접두 검색 인덱스(ix_users_handle_like_with_id = varchar_pattern_ops, id)의
                -- 정렬 연산자와 정확히 일치시켜 접두 인덱스 하나로 seek+정렬을 모두 처리한다(Sort 노드 없음).
                --   - 기본 ORDER BY handle이면 옵티마이저가 정렬을 맞추려 users_handle_key(유니크)를 골라
                --     LIKE seek 없이 전체 스캔한다(실측 20만행: 125,681행 스캔, 126,109 buffers).
                --   - COLLATE "C"로는 부족하다. pattern_ops 인덱스의 정렬 pathkey는 ~<~ 패밀리인데
                --     COLLATE "C"는 기본 text_ops 패밀리라 여전히 불일치 → 매칭 전건 읽고 Sort(642 buffers).
                --   - USING ~<~는 pathkey가 맞아떨어져 LIMIT 건수만 읽고 멈춘다(23 buffers).
                -- handle은 [0-9a-f]뿐이라 ~<~ 순서 == 기본 순서 → 결과 불변, 최종 표시는 바깥 ORDER BY가 담당.
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
                -- 결정성: 정렬 없이 뽑으면 페이지 넘김 시 후보 집합이 달라져 중복/누락 가능.
                -- 최종 표시 순서(handle, id)로 뽑아 페이지 간 후보를 고정한다.
                -- (contains는 개선4로 exact+prefix 미충족 시=매칭 적은 경우에만 실행 → 정렬 비용 무시 가능)
                ORDER BY handle, id
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
            ORDER BY s.w DESC, s.handle ASC, s.id ASC
            LIMIT (SELECT lim FROM p) OFFSET (SELECT off FROM p)
            """;

    // --- Search: contains 없는 버전 ---
    public static final String SELECT_USER_NO_CONTAINS_BY_HANDLE = """
            -- NOT MATERIALIZED: p가 여러 버킷에서 참조되어 자동 materialize되면 LIKE 패턴(q_prefix)이
            -- 불투명한 런타임 값이 되어 접두 인덱스(varchar_pattern_ops)를 못 탄다. 인라인 강제로 인덱스 사용 유지.
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
                -- USING ~<~: 접두 검색 인덱스(ix_users_handle_like_with_id = varchar_pattern_ops, id)의
                -- 정렬 연산자와 정확히 일치시켜 접두 인덱스 하나로 seek+정렬을 모두 처리한다(Sort 노드 없음).
                --   - 기본 ORDER BY handle이면 옵티마이저가 정렬을 맞추려 users_handle_key(유니크)를 골라
                --     LIKE seek 없이 전체 스캔한다(실측 20만행: 125,681행 스캔, 126,109 buffers).
                --   - COLLATE "C"로는 부족하다. pattern_ops 인덱스의 정렬 pathkey는 ~<~ 패밀리인데
                --     COLLATE "C"는 기본 text_ops 패밀리라 여전히 불일치 → 매칭 전건 읽고 Sort(642 buffers).
                --   - USING ~<~는 pathkey가 맞아떨어져 LIMIT 건수만 읽고 멈춘다(23 buffers).
                -- handle은 [0-9a-f]뿐이라 ~<~ 순서 == 기본 순서 → 결과 불변, 최종 표시는 바깥 ORDER BY가 담당.
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
