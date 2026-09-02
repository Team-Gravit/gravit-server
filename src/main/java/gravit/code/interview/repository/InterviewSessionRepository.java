package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewSessionRepository extends JpaRepository<InterviewSession, Long> {

    boolean existsByUserIdAndStatus(
            long userId,
            InterviewSessionStatus status
    );
}
