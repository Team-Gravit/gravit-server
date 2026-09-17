package gravit.code.learning.repository;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUserDto;
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

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query(value = """
            UPDATE learning
            SET consecutive_solved_days = CASE WHEN today_solved THEN consecutive_solved_days ELSE 0 END,
                today_solved            = FALSE
            WHERE today_solved = TRUE OR consecutive_solved_days <> 0
    """, nativeQuery = true)
    int resetConsecutiveDays();

    @Query("""
            SELECT new gravit.code.learning.dto.internal.ConsecutiveAtRiskUserDto(l.userId, l.consecutiveSolvedDays)
            FROM Learning l
            WHERE l.consecutiveSolvedDays >= 1 AND l.todaySolved = false
              AND EXISTS (SELECT 1 FROM User u WHERE u.id = l.userId AND u.lastAccessedAt >= :activeThreshold)
    """)
    List<ConsecutiveAtRiskUserDto> findConsecutiveAtRiskUsers(@Param("activeThreshold") LocalDateTime activeThreshold);

    @Query("""
            SELECT l.userId
            FROM Learning l
            WHERE l.consecutiveSolvedDays = 0 AND l.todaySolved = false
              AND EXISTS (SELECT 1 FROM User u WHERE u.id = l.userId AND u.lastAccessedAt >= :activeThreshold)
    """)
    List<Long> findDailyIncompleteUserIds(@Param("activeThreshold") LocalDateTime activeThreshold);
}
