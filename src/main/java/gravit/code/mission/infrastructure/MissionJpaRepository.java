package gravit.code.mission.infrastructure;

import gravit.code.mission.domain.Mission;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import org.springframework.data.domain.Pageable;

import java.util.Optional;

public interface MissionJpaRepository extends JpaRepository<Mission, Long> {
    Optional<Mission> findByUserId(Long userId);

    @Lock(LockModeType.OPTIMISTIC)
    Page<Mission> findAll(Pageable pageable);
}