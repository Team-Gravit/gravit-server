package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.response.LearningDetail;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface LearningJpaRepository extends JpaRepository<Learning,Long> {
    Optional<Learning> findByUserId(long userId);

    @Lock(LockModeType.OPTIMISTIC)
    Page<Learning> findAll(Pageable pageable);

    @Query("""
        SELECT new gravit.code.learning.dto.response.LearningDetail(
            l.consecutiveSolvedDays, l.planetConquestRate, l.recentSolvedChapterId, c.title, c.description, 0.0
        )
        FROM Learning l
        JOIN Chapter c ON c.id = l.recentSolvedChapterId
        WHERE l.userId = :userId
    """)
    Optional<LearningDetail> findLearningDetailByUserId(@Param("userId")long userId);
}
