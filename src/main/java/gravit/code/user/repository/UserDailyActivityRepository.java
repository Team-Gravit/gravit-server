package gravit.code.user.repository;

import gravit.code.user.domain.UserDailyActivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;

public interface UserDailyActivityRepository extends JpaRepository<UserDailyActivity, Long> {

    @Modifying
    @Query(value = """
            INSERT INTO user_daily_activity (user_id, activity_date)
            VALUES (:userId, :activityDate)
            ON CONFLICT (activity_date, user_id) DO NOTHING
            """, nativeQuery = true)
    int insertIfAbsent(
            @Param("userId") long userId,
            @Param("activityDate") LocalDate activityDate
    );
}
