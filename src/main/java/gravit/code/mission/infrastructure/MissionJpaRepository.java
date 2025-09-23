package gravit.code.mission.infrastructure;

import gravit.code.mission.domain.Mission;
import gravit.code.mission.dto.MissionSummary;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface MissionJpaRepository extends JpaRepository<Mission, Long> {
    Optional<Mission> findByUserId(long userId);

    @Lock(LockModeType.OPTIMISTIC)
    Page<Mission> findAll(Pageable pageable);

    @Query("""
        SELECT new gravit.code.mission.dto.MissionSummary(m.missionType, m.isCompleted)
        FROM Mission m
        WHERE m.userId = :userId
    """)
    Optional<MissionSummary> findMissionSummaryByUserId(@Param("userId") long userId);
}