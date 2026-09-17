package gravit.code.user.repository.sql;

import lombok.experimental.UtilityClass;

@UtilityClass
public class UserCleanDeletionSql {

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
              d_user_mission AS (
                DELETE FROM user_mission WHERE user_id = :id
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
              ),
              d_interview_feedback AS (
                DELETE FROM interview_feedback
                WHERE answer_id IN (
                  SELECT id FROM interview_answer
                  WHERE session_id IN (SELECT id FROM interview_session WHERE user_id = :id)
                )
              ),
              d_interview_answer AS (
                DELETE FROM interview_answer
                WHERE session_id IN (SELECT id FROM interview_session WHERE user_id = :id)
              ),
              d_interview_session_topic AS (
                DELETE FROM interview_session_topic
                WHERE session_id IN (SELECT id FROM interview_session WHERE user_id = :id)
              ),
              d_interview_session AS (
                DELETE FROM interview_session WHERE user_id = :id
              )
            DELETE FROM users WHERE id = :id;
        """;
}
