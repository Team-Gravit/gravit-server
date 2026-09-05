package gravit.code.admin.repository;

import gravit.code.admin.dto.internal.DailyActiveUserCountDto;
import gravit.code.admin.dto.internal.MonthlyActiveUserCountDto;
import gravit.code.user.domain.UserDailyActivity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface AdminActiveUserRepository extends JpaRepository<UserDailyActivity, Long> {

    @Query("""
            SELECT new gravit.code.admin.dto.internal.DailyActiveUserCountDto(uda.activityDate, COUNT(uda.userId))
            FROM UserDailyActivity uda
            WHERE uda.activityDate BETWEEN :startDate AND :endDate
            GROUP BY uda.activityDate
            ORDER BY uda.activityDate
    """)
    List<DailyActiveUserCountDto> findDailyActiveUserCounts(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    @Query("""
            SELECT new gravit.code.admin.dto.internal.MonthlyActiveUserCountDto(
                EXTRACT(YEAR FROM uda.activityDate), EXTRACT(MONTH FROM uda.activityDate), COUNT(DISTINCT uda.userId)
            )
            FROM UserDailyActivity uda
            WHERE uda.activityDate BETWEEN :startDate AND :endDate
            GROUP BY EXTRACT(YEAR FROM uda.activityDate), EXTRACT(MONTH FROM uda.activityDate)
            ORDER BY EXTRACT(YEAR FROM uda.activityDate), EXTRACT(MONTH FROM uda.activityDate)
    """)
    List<MonthlyActiveUserCountDto> findMonthlyActiveUserCounts(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
