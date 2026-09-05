package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewAnswer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InterviewAnswerRepository extends JpaRepository<InterviewAnswer, Long> {

    List<InterviewAnswer> findAllBySessionIdOrderByDisplayOrderAsc(long sessionId);
}
