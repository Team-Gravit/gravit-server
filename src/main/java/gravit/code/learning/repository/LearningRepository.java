package gravit.code.learning.repository;

import gravit.code.learning.domain.Learning;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.List;
import java.util.Optional;

public interface LearningRepository extends JpaRepository<Learning,Long> {

    Optional<Learning> findByUserId(long userId);

    @Lock(LockModeType.OPTIMISTIC)
    List<Learning> findAll();
}
