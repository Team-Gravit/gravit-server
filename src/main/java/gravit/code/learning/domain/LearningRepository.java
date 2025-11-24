package gravit.code.learning.domain;

import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface LearningRepository {
    Optional<Learning> findByUserId(long userId);
    List<Learning> findAll(Pageable pageable);
    Learning save(Learning learning);
    void saveAll(List<Learning> learnings);
}
