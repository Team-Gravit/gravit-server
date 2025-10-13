package gravit.code.user.infrastructure.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class UserCleanDeletionSql {

    public static final String CLEAN_USER_DELETION_SQL = """
            WITH
              d_friends AS (
                DELETE FROM friends
                WHERE follower_id = :id OR followee_id = :id
              ),
              d_notice AS (DELETE FROM notice WHERE author_id = :id),
              d_chapter AS (DELETE FROM chapter_progress WHERE user_id = :id),
              d_unit    AS (DELETE FROM unit_progress    WHERE user_id = :id),
              d_lesson  AS (DELETE FROM lesson_progress  WHERE user_id = :id),
              d_problem AS (DELETE FROM problem_progress WHERE user_id = :id),
              d_learning AS (DELETE FROM learning WHERE user_id = :id),
              d_ulh AS (DELETE FROM user_league_history WHERE user_id = :id),
              d_ul  AS (DELETE FROM user_league         WHERE user_id = :id),
              d_mission AS (DELETE FROM mission  WHERE user_id = :id),
              d_ub   AS (DELETE FROM user_badge              WHERE user_id = :id),
              d_ums  AS (DELETE FROM user_mission_stat       WHERE user_id = :id),
              d_upc  AS (DELETE FROM user_planet_completion  WHERE user_id = :id),
              d_uqs  AS (DELETE FROM user_qualified_solve_stat WHERE user_id = :id)
            DELETE FROM users WHERE id = :id;
        """;

    /**
     * 삭제 건수를 함께 리턴하는 버전 (운영 로그/모니터링에 유용)
     * - 단일 로우를 반환하며 각 컬럼에 테이블별 삭제 건수가 들어감
     * - 현재 사용은 x, 추후 지표 관리 할 때 힌트로 남겨둠
     */
    public static final String CLEAN_USER_DELETION_WITH_COUNTS_SQL = """
        WITH
        d_friends AS (
          DELETE FROM friends
          WHERE follower_id = :id OR followee_id = :id
          RETURNING 1
        ),
        d_chapter AS (
          DELETE FROM chapter_progress WHERE user_id = :id
          RETURNING 1
        ),
        d_unit AS (
          DELETE FROM unit_progress WHERE user_id = :id
          RETURNING 1
        ),
        d_lesson AS (
          DELETE FROM lesson_progress WHERE user_id = :id
          RETURNING 1
        ),
        d_problem AS (
          DELETE FROM problem_progress WHERE user_id = :id
          RETURNING 1
        ),
        d_learning AS (
          DELETE FROM learning WHERE user_id = :id
          RETURNING 1
        ),
        d_ulh AS (
          DELETE FROM user_league_history WHERE user_id = :id
          RETURNING 1
        ),
        d_ul AS (
          DELETE FROM user_league WHERE user_id = :id
          RETURNING 1
        ),
        d_mission AS (
          DELETE FROM mission WHERE user_id = :id
          RETURNING 1
        ),
        d_report AS (
          DELETE FROM report WHERE user_id = :id
          RETURNING 1
        ),
        d_ub AS (
          DELETE FROM user_badge WHERE user_id = :id
          RETURNING 1
        ),
        d_ums AS (
          DELETE FROM user_mission_stat WHERE user_id = :id
          RETURNING 1
        ),
        d_upc AS (
          DELETE FROM user_planet_completion WHERE user_id = :id
          RETURNING 1
        ),
        d_uqs AS (
          DELETE FROM user_qualified_solve_stat WHERE user_id = :id
          RETURNING 1
        ),
        d_user AS (
          DELETE FROM users WHERE id = :id
          RETURNING 1
        )
        SELECT
          (SELECT COUNT(*) FROM d_friends) AS friends,
          (SELECT COUNT(*) FROM d_chapter) AS chapter_progress,
          (SELECT COUNT(*) FROM d_unit)    AS unit_progress,
          (SELECT COUNT(*) FROM d_lesson)  AS lesson_progress,
          (SELECT COUNT(*) FROM d_problem) AS problem_progress,
          (SELECT COUNT(*) FROM d_learning) AS learning,
          (SELECT COUNT(*) FROM d_ulh)     AS user_league_history,
          (SELECT COUNT(*) FROM d_ul)      AS user_league,
          (SELECT COUNT(*) FROM d_mission) AS mission,
          (SELECT COUNT(*) FROM d_report)  AS report,
          (SELECT COUNT(*) FROM d_ub)      AS user_badge,
          (SELECT COUNT(*) FROM d_ums)     AS user_mission_stat,
          (SELECT COUNT(*) FROM d_upc)     AS user_planet_completion,
          (SELECT COUNT(*) FROM d_uqs)     AS user_qualified_solve_stat,
          (SELECT COUNT(*) FROM d_user)    AS users
        """;
}
