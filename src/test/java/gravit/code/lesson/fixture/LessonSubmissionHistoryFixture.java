package gravit.code.lesson.fixture;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDateTime;

@TestComponent
@RequiredArgsConstructor
public class LessonSubmissionHistoryFixture {

    private static final int LEARNING_TIME = 120;

    private final JdbcTemplate jdbcTemplate;

    public void 제출(
            long userId,
            long lessonId,
            int accuracy,
            LocalDateTime createdAt
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO lesson_submission (learning_time, accuracy, lesson_id, user_id, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                LEARNING_TIME, accuracy, lessonId, userId, createdAt, createdAt
        );
    }
}
