package gravit.code.social.repository;

import gravit.code.social.domain.Congratulation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;

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

    boolean existsByUserIdAndFeedId(long userId, long feedId);
}
