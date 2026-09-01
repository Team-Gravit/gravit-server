package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewAnswer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface InterviewAnswerRepository extends JpaRepository<InterviewAnswer, Long> {

    Optional<InterviewAnswer> findBySessionIdAndDisplayOrder(
            long sessionId,
            int displayOrder
    );
}
