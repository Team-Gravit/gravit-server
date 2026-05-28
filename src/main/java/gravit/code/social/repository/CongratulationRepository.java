package gravit.code.social.repository;

import gravit.code.social.domain.Congratulation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface CongratulationRepository extends JpaRepository<Congratulation, Long> {

    @Query("""
            SELECT COUNT(c) FROM Congratulation c
            WHERE c.userId = :userId AND c.actorId = :actorId AND c.createdAt >= :startOfDay
            """)
    long countTodayByUserIdAndActorId(
            @Param("userId") long userId,
            @Param("actorId") long actorId,
            @Param("startOfDay") LocalDateTime startOfDay
    );

    @Query("""
            SELECT c.actorId FROM Congratulation c
            WHERE c.userId = :userId AND c.actorId IN :actorIds AND c.createdAt >= :startOfDay
            GROUP BY c.actorId HAVING COUNT(c) >= 3
            """)
    List<Long> findActorIdsWithLimitReached(
            @Param("userId") long userId,
            @Param("actorIds") List<Long> actorIds,
            @Param("startOfDay") LocalDateTime startOfDay
    );

    boolean existsByUserIdAndFeedId(long userId, long feedId);
}
