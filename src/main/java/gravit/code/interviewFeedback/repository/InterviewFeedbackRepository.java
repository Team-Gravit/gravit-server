package gravit.code.interviewFeedback.repository;

import gravit.code.interviewFeedback.domain.InterviewFeedback;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewFeedbackRepository extends JpaRepository<InterviewFeedback, Long> {
}
