package gravit.code.domain.friend.infrastructure.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class FriendsHandleCountQuerySql {

    // --- COUNT: contains 포함 버전 ---
    public static final String COUNT_WITH_CONTAINS_BY_HANDLE = """
            WITH p AS (
              SELECT :me::bigint AS me,
              :q::text AS q,
              :q_prefix::text AS q_prefix,
              :q_contains::text AS q_contains
            ),
            exact_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me AND u.handle = p.q
            ),
            prefix_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me
                AND u.handle LIKE :q_prefix
                AND u.handle <> p.q
            ),
            contains_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me
                AND u.handle LIKE p.q_contains
                AND u.handle <> p.q
                AND handle NOT LIKE p.q_prefix
            )
            SELECT (SELECT c FROM exact_cnt) + (SELECT c FROM prefix_cnt) + (SELECT c FROM contains_cnt)
            """;

    // --- COUNT: contains 없는 버전 ---
    public static final String COUNT_NO_CONTAINS_BY_HANDLE = """
            WITH p AS (
              SELECT :me::bigint AS me,
              :q::text AS q,
              :q_prefix::text AS q_prefix
            ),
            exact_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me AND u.handle = p.q
            ),
            prefix_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me
                AND u.handle LIKE p.q_prefix
                AND u.handle <> p.q
            )
            SELECT (SELECT c FROM exact_cnt) + (SELECT c FROM prefix_cnt)
            """;
}
