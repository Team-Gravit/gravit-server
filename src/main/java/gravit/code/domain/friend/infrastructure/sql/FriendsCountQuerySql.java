package gravit.code.domain.friend.infrastructure.sql;

public final class FriendsCountQuerySql {
    private FriendsCountQuerySql() {
    }

    // --- COUNT: contains 포함 버전 ---
    public static final String COUNT_WITH_CONTAINS = """
            WITH p AS (
              SELECT :me::bigint AS me, :q::text AS q
            ),
            exact_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me AND u.handle = p.q
            ),
            prefix_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me
                AND u.handle >= p.q
                AND u.handle <  p.q || '{'
                AND u.handle <> p.q
            ),
            contains_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me
                AND u.handle LIKE :q_contains
                AND u.handle <> p.q
                AND u.handle NOT LIKE p.q || '%%'
            )
            SELECT (SELECT c FROM exact_cnt) + (SELECT c FROM prefix_cnt) + (SELECT c FROM contains_cnt)
            """;

    // --- COUNT: contains 없는 버전 ---
    public static final String COUNT_NO_CONTAINS = """
            WITH p AS (
              SELECT :me::bigint AS me, :q::text AS q
            ),
            exact_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me AND u.handle = p.q
            ),
            prefix_cnt AS (
              SELECT count(*) c FROM users u, p
              WHERE u.id <> p.me
                AND u.handle >= p.q
                AND u.handle <  p.q || '{'
                AND u.handle <> p.q
            )
            SELECT (SELECT c FROM exact_cnt) + (SELECT c FROM prefix_cnt)
            """;
}
