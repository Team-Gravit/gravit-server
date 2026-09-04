package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewSession;
import org.springframework.data.jpa.repository.JpaRepository;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.internal.InterviewSessionAverageDto;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface InterviewSessionRepository extends JpaRepository<InterviewSession, Long> {

    Slice<InterviewSession> findAllByUserIdAndStatus(
            long userId,
            InterviewSessionStatus status,
            Pageable pageable
    );

    long countByUserIdAndStatus(
            long userId,
            InterviewSessionStatus status
    );

    @Query("""
            SELECT s FROM InterviewSession s
            WHERE s.userId = :userId AND s.status = :status
            ORDER BY s.startedAt DESC, s.id DESC
    """)
    List<InterviewSession> findRecentByUserIdAndStatus(
            @Param("userId") long userId,
            @Param("status") InterviewSessionStatus status,
            Pageable pageable
    );

    @Query("""
            SELECT s FROM InterviewSession s
            WHERE s.userId = :userId AND s.status = :status AND s.startedAt <= :startedAt
            ORDER BY s.startedAt DESC, s.id DESC
    """)
    List<InterviewSession> findRecentByUserIdAndStatusStartedAtOrBefore(
            @Param("userId") long userId,
            @Param("status") InterviewSessionStatus status,
            @Param("startedAt") LocalDateTime startedAt,
            Pageable pageable
    );

    @Query("""
            SELECT new gravit.code.interview.dto.internal.InterviewSessionAverageDto(
                COALESCE(AVG(s.accuracyScore), 0.0), COALESCE(AVG(s.deliveryScore), 0.0)
            )
            FROM InterviewSession s
            WHERE s.status = :status
    """)
    InterviewSessionAverageDto findAverageScoresByStatus(@Param("status") InterviewSessionStatus status);
}
