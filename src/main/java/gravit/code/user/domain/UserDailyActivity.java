package gravit.code.user.domain;

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
        name = "user_daily_activity",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_user_daily_activity_date_user",
                columnNames = {"activity_date", "user_id"}
        )
)
public class UserDailyActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private long userId;

    @Column(name = "activity_date", nullable = false)
    private LocalDate activityDate;

    @Builder(access = AccessLevel.PRIVATE)
    private UserDailyActivity(
            long userId,
            LocalDate activityDate
    ) {
        this.userId = userId;
        this.activityDate = activityDate;
    }

    public static UserDailyActivity create(
            long userId,
            LocalDate activityDate
    ) {
        return UserDailyActivity.builder()
                .userId(userId)
                .activityDate(activityDate)
                .build();
    }
}
