package gravit.code.userLeague.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class LeaguePointGrantQuerySql {

    public static final String FIND_UNGRANTED_FIRST_LESSON_SUBMISSIONS = """
            SELECT first.user_id,
                   first.lesson_id,
                   first.accuracy
            FROM (
                SELECT DISTINCT ON (ls.user_id, ls.lesson_id) ls.user_id, ls.lesson_id, ls.accuracy
                FROM lesson_submission ls
                WHERE ls.created_at >= :since AND ls.created_at < :until
                ORDER BY ls.user_id, ls.lesson_id, ls.created_at, ls.id
            ) first
            WHERE NOT EXISTS (
                    SELECT 1 FROM league_point_grant g
                    WHERE g.source_type = 'LESSON' AND g.source_id = first.lesson_id AND g.user_id = first.user_id)
              AND NOT EXISTS (
                    SELECT 1 FROM lesson_submission prev
                    WHERE prev.user_id = first.user_id AND prev.lesson_id = first.lesson_id AND prev.created_at < :since)
            LIMIT :limit
            """;
}
