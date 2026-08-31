package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewSession;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewSessionRepository extends JpaRepository<InterviewSession, Long> {
}
