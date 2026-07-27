package gravit.code.mission.repository;

import gravit.code.mission.domain.UserMission;
import gravit.code.mission.dto.internal.AssignedMission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface UserMissionRepository extends JpaRepository<UserMission, Long> {

    @Query("""
        SELECT new gravit.code.mission.dto.internal.AssignedMission(um, m)
        FROM UserMission um
        JOIN Mission m ON m.id = um.missionId
        WHERE um.userId = :userId AND um.assignedDate = :assignedDate
    """)
    Optional<AssignedMission> findAssignedMission(
            @Param("userId") long userId,
            @Param("assignedDate") LocalDate assignedDate
    );

    @Query("""
        SELECT um.userId
        FROM UserMission um
        WHERE um.assignedDate = :assignedDate AND um.userId IN :userIds
    """)
    Set<Long> findAssignedUserIds(
            @Param("assignedDate") LocalDate assignedDate,
            @Param("userIds") List<Long> userIds
    );

    boolean existsByUserIdAndAssignedDate(
            long userId,
            LocalDate assignedDate
    );

    // 이미 있으면 예외 없이 0을 반환한다. 중복 배정 판정을 DB에 맡겨 호출부에 try-catch가 생기지 않게 한다
    // flushAutomatically: BEFORE_COMMIT 리스너 안에서 실행될 때 외부 트랜잭션의 미flush 변경이
    // clearAutomatically에 쓸려가지 않도록 명시한다
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query(value = """
        INSERT INTO user_mission (user_id, mission_id, assigned_date, progress_count, created_at, updated_at)
        VALUES (:userId, :missionId, :assignedDate, 0, :now, :now)
        ON CONFLICT (user_id, assigned_date) DO NOTHING
    """, nativeQuery = true)
    int insertIfAbsent(
            @Param("userId") long userId,
            @Param("missionId") long missionId,
            @Param("assignedDate") LocalDate assignedDate,
            @Param("now") LocalDateTime now
    );

    // 아직 완료되지 않았을 때만 1을 반환한다. XP 중복 지급 차단의 근거가 되는 쿼리다
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
        UPDATE UserMission um
        SET um.completedAt = :now
        WHERE um.id = :id AND um.completedAt IS NULL
    """)
    int completeIfNotCompleted(
            @Param("id") long id,
            @Param("now") LocalDateTime now
    );
}
