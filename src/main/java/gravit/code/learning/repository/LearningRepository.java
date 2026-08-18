package gravit.code.learning.repository;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface LearningRepository extends JpaRepository<Learning,Long> {

    Optional<Learning> findByUserId(long userId);

    boolean existsByUserId(long userId);

    @Modifying(clearAutomatically = true)
    @Query(value = """
        UPDATE learning
        SET consecutive_solved_days = CASE WHEN today_solved THEN consecutive_solved_days ELSE 0 END,
            today_solved            = FALSE
        WHERE today_solved = TRUE OR consecutive_solved_days <> 0
    """, nativeQuery = true)
    int resetConsecutiveDays();

    // 연속학습 위기 대상. 단, 미접속 14일 이상 유저는 장기 미접속 알림으로 대체되므로 제외(activeThreshold 이후 접속자만)
    @Query("""
            SELECT new gravit.code.learning.dto.internal.ConsecutiveAtRiskUser(l.userId, l.consecutiveSolvedDays)
            FROM Learning l
            WHERE l.consecutiveSolvedDays >= 1 AND l.todaySolved = false
              AND EXISTS (SELECT 1 FROM User u WHERE u.id = l.userId AND u.lastAccessedAt >= :activeThreshold)
    """)
    List<ConsecutiveAtRiskUser> findConsecutiveAtRiskUsers(@Param("activeThreshold") LocalDateTime activeThreshold);

    // 오늘 미완료 대상. 위와 동일하게 미접속 14일 이상 유저는 제외
    @Query("""
            SELECT l.userId
            FROM Learning l
            WHERE l.consecutiveSolvedDays = 0 AND l.todaySolved = false
              AND EXISTS (SELECT 1 FROM User u WHERE u.id = l.userId AND u.lastAccessedAt >= :activeThreshold)
    """)
    List<Long> findDailyIncompleteUserIds(@Param("activeThreshold") LocalDateTime activeThreshold);
}
