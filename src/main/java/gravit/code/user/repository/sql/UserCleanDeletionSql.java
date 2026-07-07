package gravit.code.user.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class UserCleanDeletionSql {

    /**
     * 사용자 및 관련 데이터를 완전 삭제하는 SQL
     *
     * 단일 {@code WITH ... DELETE} 문이므로 FK 제약은 문장 종료 시점에 일괄 검사된다.
     * (CTE 실행 순서와 무관하게 참조/피참조 행이 모두 사라진 상태로 검사되므로 순서 이슈가 없다.)
     *
     * 삭제 대상:
     * 1. 소셜/알림 (congratulation, notification, fcm_token, social_feed, user_feed)
     *    - congratulation·notification 은 users 를 참조하는 FK 보유 → users 삭제 전 제거 필수
     * 2. 친구 관계 (friends, 양방향)
     * 3. 공지사항 (notice)
     * 4. 학습 관련 (learning, lesson_submission, problem_submission, bookmark, wrong_answered_note, daily_learning_record)
     * 5. 리그/시즌 (user_league_history, user_league)
     * 6. 미션/리포트 (mission, report)
     * 7. 문의 (inquiry_answer → inquiry)
     * 8. 사용자 (users)
     *
     * NOTE: user_badge·user_mission_stat·user_planet_completion·user_qualified_solve_stat 는
     *       V9(drop_badge_tables)에서 삭제된 테이블이라 더 이상 대상에 포함하지 않는다.
     */
    public static final String CLEAN_USER_DELETION_SQL = """
            WITH
              d_congratulation AS (
                DELETE FROM congratulation
                WHERE user_id = :id OR actor_id = :id
                   OR feed_id IN (SELECT id FROM social_feed WHERE actor_id = :id)
              ),
              d_notification AS (
                DELETE FROM notification WHERE user_id = :id
              ),
              d_fcm_token AS (
                DELETE FROM fcm_token WHERE user_id = :id
              ),
              d_social_feed AS (
                DELETE FROM social_feed WHERE actor_id = :id
              ),
              d_user_feed AS (
                DELETE FROM user_feed WHERE user_id = :id
              ),
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
              d_wrong_answered_note AS (
                DELETE FROM wrong_answered_note WHERE user_id = :id
              ),
              d_daily_learning_record AS (
                DELETE FROM daily_learning_record WHERE user_id = :id
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
              d_inquiry_answer AS (
                DELETE FROM inquiry_answer
                WHERE inquiry_id IN (SELECT id FROM inquiry WHERE user_id = :id)
              ),
              d_inquiry AS (
                DELETE FROM inquiry WHERE user_id = :id
              )
            DELETE FROM users WHERE id = :id;
        """;
}
