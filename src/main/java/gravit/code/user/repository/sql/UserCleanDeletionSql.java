package gravit.code.user.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class UserCleanDeletionSql {

    /**
     * 사용자 및 관련 데이터를 완전 삭제하는 SQL
     *
     * 삭제 순서:
     * 1. 친구 관계 (양방향)
     * 2. 공지사항 (notice)
     * 3. 학습 관련 (learning, lesson_submission, problem_submission, bookmark)
     * 4. 리그/시즌 (user_league_history, user_league)
     * 5. 미션/리포트 (mission, report)
     * 6. 뱃지 및 사용자 통계 (user_badge, user_mission_stat, user_planet_completion, user_qualified_solve_stat)
     * 7. 사용자 (users)
     */
    public static final String CLEAN_USER_DELETION_SQL = """
            WITH
              d_friends AS (
                DELETE FROM friends
                WHERE follower_id = :id OR followee_id = :id
              ),
              d_notice AS (
                DELETE FROM notice WHERE author_id = :id
              ),
              d_learning AS (
                DELETE FROM learning WHERE user_id = :id
              ),
              d_lesson_submission AS (
                DELETE FROM lesson_submission WHERE user_id = :id
              ),
              d_problem_submission AS (
                DELETE FROM problem_submission WHERE user_id = :id
              ),
              d_bookmark AS (
                DELETE FROM bookmark WHERE user_id = :id
              ),
              d_ulh AS (
                DELETE FROM user_league_history WHERE user_id = :id
              ),
              d_ul AS (
                DELETE FROM user_league WHERE user_id = :id
              ),
              d_mission AS (
                DELETE FROM mission WHERE user_id = :id
              ),
              d_report AS (
                DELETE FROM report WHERE user_id = :id
              ),
              d_ub AS (
                DELETE FROM user_badge WHERE user_id = :id
              ),
              d_ums AS (
                DELETE FROM user_mission_stat WHERE user_id = :id
              ),
              d_upc AS (
                DELETE FROM user_planet_completion WHERE user_id = :id
              ),
              d_uqs AS (
                DELETE FROM user_qualified_solve_stat WHERE user_id = :id
              )
            DELETE FROM users WHERE id = :id;
        """;
}
