package gravit.code.learning.domain;

import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface LearningRepository {
    void save(Learning learning);
    Optional<Learning> findByUserId(Long userId);
    List<Learning> findAll(Pageable pageable);
    void saveAll(List<Learning> learnings);
}
