package gravit.code.dailyLearningRecord.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(
        name = "daily_learning_record",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_daily_learning_record_user_date",
                columnNames = {"user_id", "solved_date"}
        )
)
public class DailyLearningRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "solved_date", nullable = false)
    private LocalDate solvedDate;

    @Column(name = "solved_lesson_count", nullable = false)
    private int solvedLessonCount;

    @Builder(access = AccessLevel.PRIVATE)
    private DailyLearningRecord(
            long userId,
            LocalDate solvedDate
    ) {
        this.userId = userId;
        this.solvedDate = solvedDate;
        this.solvedLessonCount = 0;
    }

    public static DailyLearningRecord create(
            long userId,
            LocalDate solvedDate
    ) {
        return DailyLearningRecord.builder()
                .userId(userId)
                .solvedDate(solvedDate)
                .build();
    }

    public void increaseSolvedLessonCount() {
        this.solvedLessonCount++;
    }
}
