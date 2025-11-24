package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Learning;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;

public interface LearningJpaRepository extends JpaRepository<Learning,Long> {
    Optional<Learning> findByUserId(long userId);

    @Lock(LockModeType.OPTIMISTIC)
    Page<Learning> findAll(Pageable pageable);
}
