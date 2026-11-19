package gravit.code.metricReport.fixture;

import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserDailyActivityFixture;
import gravit.code.user.fixture.UserFixture;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 지표 집계 테스트용 저장형 fixture. 시각 컬럼을 정확히 지정하려고 JDBC로 직접 적재한다.
 */
@TestComponent
@RequiredArgsConstructor
public class MetricFixture {

    private static final AtomicInteger USER_INDEX = new AtomicInteger();

    private final UserFixture userFixture;
    private final UserDailyActivityFixture userDailyActivityFixture;

    private final JdbcTemplate jdbcTemplate;

    public long 가입한_사용자(LocalDateTime createdAt) {
        User user = userFixture.일반_유저(USER_INDEX.incrementAndGet());
        jdbcTemplate.update("UPDATE users SET created_at = ? WHERE id = ?", createdAt, user.getId());
        return user.getId();
    }

    public long 탈퇴한_사용자(LocalDateTime createdAt) {
        long userId = 가입한_사용자(createdAt);
        jdbcTemplate.update(
                "UPDATE users SET status = 'DELETED', deleted_at = ?, handle = NULL WHERE id = ?",
                createdAt.plusHours(1),
                userId
        );
        return userId;
    }

    public void 활동_이력(
            long userId,
            LocalDate... activityDates
    ) {
        userDailyActivityFixture.활동_이력(userId, activityDates);
    }

    public void 레슨_제출(
            long userId,
            int accuracy,
            LocalDateTime createdAt
    ) {
        jdbcTemplate.update(
                "INSERT INTO lesson_submission (learning_time, lesson_id, user_id, accuracy, created_at, updated_at) VALUES (60, 1, ?, ?, ?, ?)",
                userId,
                accuracy,
                createdAt,
                createdAt
        );
    }

    public void 면접_세션(
            String status,
            LocalDateTime startedAt,
            LocalDateTime endedAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO interview_session (user_id, attempt_count, mode, input_type, difficulty, status,
                                               accuracy_score, delivery_score, grading_attempt_count,
                                               accuracy_max_score, structure_max_score, clarity_max_score,
                                               started_at, ended_at, created_at, updated_at)
                VALUES (1, 1, 'COMMON_CS', 'TEXT', 'NORMAL', ?, 0, 0, 0, 70, 15, 15, ?, ?, ?, ?)
                """,
                status,
                startedAt,
                endedAt,
                startedAt,
                startedAt
        );
    }

    public void 채점_결과(
            long answerId,
            LocalDateTime createdAt
    ) {
        jdbcTemplate.update(
                "INSERT INTO interview_feedback (answer_id, accuracy_score, structure_score, clarity_score, created_at, updated_at) VALUES (?, 10, 2, 2, ?, ?)",
                answerId,
                createdAt,
                createdAt
        );
    }

    public void 신고(
            String reportType,
            long problemId,
            boolean resolved,
            LocalDateTime submittedAt
    ) {
        jdbcTemplate.update(
                "INSERT INTO report (is_resolved, problem_id, submitted_at, user_id, content, report_type) VALUES (?, ?, ?, 1, '신고 내용', ?)",
                resolved,
                problemId,
                submittedAt,
                reportType
        );
    }

    public void 문의(
            String type,
            String title,
            String status,
            LocalDateTime createdAt
    ) {
        jdbcTemplate.update(
                "INSERT INTO inquiry (title, type, content, status, user_id, created_at, updated_at) VALUES (?, ?, '문의 내용', ?, 1, ?, ?)",
                title,
                type,
                status,
                createdAt,
                createdAt
        );
    }
}
