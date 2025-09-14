package gravit.code.learning.domain;

import java.util.List;
import java.util.Optional;

public interface LearningRepository {
    void save(Learning learning);
    Optional<Learning> findByUserId(Long userId);
    List<Learning> findAllByTodaySolved(boolean todaySolved);
    void saveAll(List<Learning> learnings);
}
