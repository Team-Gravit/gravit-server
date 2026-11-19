package gravit.code.metricReport.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class ServiceMetricSql {

    public static final String COUNT_SIGNUPS = """
            SELECT COUNT(*)
            FROM users
            WHERE created_at >= :startAt AND created_at < :endAt
            """;

    public static final String COUNT_DAILY_ACTIVITIES = """
            SELECT COUNT(*)
            FROM user_daily_activity
            WHERE activity_date BETWEEN :startDate AND :endDate
            """;

    public static final String COUNT_DISTINCT_ACTIVE_USERS = """
            SELECT COUNT(DISTINCT user_id)
            FROM user_daily_activity
            WHERE activity_date BETWEEN :startDate AND :endDate
            """;

    public static final String FIND_RETENTION = """
            SELECT COUNT(*) AS cohort_size,
                   COUNT(*) FILTER (WHERE EXISTS (
                       SELECT 1
                       FROM user_daily_activity uda
                       WHERE uda.user_id = u.id
                         AND uda.activity_date = CAST(u.created_at AS date) + CAST(:dayOffset AS integer)
                   )) AS retained_count
            FROM users u
            WHERE u.created_at >= :startAt AND u.created_at < :endAt
            """;

    public static final String FIND_LESSON_METRIC = """
            SELECT COUNT(*) AS submission_count,
                   COUNT(DISTINCT user_id) AS learner_count,
                   CAST(AVG(accuracy) AS double precision) AS average_accuracy
            FROM lesson_submission
            WHERE created_at >= :startAt AND created_at < :endAt
            """;

    public static final String FIND_INTERVIEW_METRIC = """
            SELECT (SELECT COUNT(*)
                    FROM interview_session
                    WHERE started_at >= :startAt AND started_at < :endAt) AS started_count,
                   (SELECT COUNT(*)
                    FROM interview_session
                    WHERE status <> 'ABANDONED' AND ended_at >= :startAt AND ended_at < :endAt) AS submitted_count,
                   (SELECT COUNT(*)
                    FROM interview_feedback
                    WHERE created_at >= :startAt AND created_at < :endAt) AS graded_answer_count
            """;

    public static final String COUNT_REPORTS_BY_TYPE = """
            SELECT report_type AS type, COUNT(*) AS count
            FROM report
            WHERE submitted_at >= :startAt AND submitted_at < :endAt
            GROUP BY report_type
            ORDER BY count DESC, report_type
            """;

    public static final String FIND_REPORTS = """
            SELECT id, report_type, problem_id, submitted_at
            FROM report
            WHERE submitted_at >= :startAt AND submitted_at < :endAt
            ORDER BY submitted_at DESC, id DESC
            LIMIT :limit
            """;

    public static final String COUNT_INQUIRIES_BY_TYPE = """
            SELECT type, COUNT(*) AS count
            FROM inquiry
            WHERE created_at >= :startAt AND created_at < :endAt
            GROUP BY type
            ORDER BY count DESC, type
            """;

    public static final String COUNT_PENDING_INQUIRIES = """
            SELECT COUNT(*)
            FROM inquiry
            WHERE status = 'PENDING'
            """;

    public static final String FIND_INQUIRIES = """
            SELECT id, type, title, created_at
            FROM inquiry
            WHERE created_at >= :startAt AND created_at < :endAt
            ORDER BY created_at DESC, id DESC
            LIMIT :limit
            """;
}
