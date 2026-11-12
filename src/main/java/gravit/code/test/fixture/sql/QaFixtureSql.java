package gravit.code.test.fixture.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class QaFixtureSql {

    public static final String SET_LOCAL_TIME_ZONE_SQL = "SET LOCAL TIME ZONE 'Asia/Seoul'";

    public static final String PREREQUISITE_SQL = """
            SELECT
                (SELECT count(*) FROM league) >= 15
                AND (
                    SELECT count(*)
                    FROM mission
                    WHERE code IN ('COMPLETE_LESSON_ONE', 'COMPLETE_LESSONS_TWO')
                ) = 2
                AND NOT EXISTS (
                    SELECT 1
                    FROM (VALUES (1, 10), (2, 6), (3, 1)) AS need(chapter_id, lesson_count)
                    WHERE need.lesson_count > (
                        SELECT count(*)
                        FROM lesson l
                        JOIN unit u ON u.id = l.unit_id
                        WHERE u.chapter_id = need.chapter_id
                    )
                )
                AND NOT EXISTS (
                    SELECT 1
                    FROM (VALUES ('DATA_STRUCTURE', 3), ('NETWORK', 2), ('SERVER_COMMON', 1),
                                 ('JAVA', 2), ('SPRING_BOOT', 2)) AS need(topic, question_count)
                    WHERE need.question_count > (
                        SELECT count(*)
                        FROM interview_question iq
                        WHERE iq.topic = need.topic
                          AND iq.is_active
                          AND iq.difficulty = 'NORMAL'
                    )
                )
            """;

    public static final String FIND_USER_IDS_SQL = """
            SELECT id
            FROM users
            WHERE provider_id LIKE :providerIdPattern
            """;

    public static final String FIND_RANK_MEMBERS_SQL = """
            SELECT ul.season_id, ul.league_id, ul.user_id, ul.league_point
            FROM user_league ul
            JOIN users u ON u.id = ul.user_id
            WHERE u.provider_id LIKE :providerIdPattern
              AND u.deleted_at IS NULL
            """;

    public static final String FIND_PERSONA_USER_IDS_SQL = """
            SELECT provider_id, id
            FROM users
            WHERE provider_id IN (:providerIds)
            """;

    public static final String DELETE_USER_DAILY_ACTIVITY_SQL = """
            DELETE FROM user_daily_activity
            WHERE user_id IN (:userIds)
            """;
}
