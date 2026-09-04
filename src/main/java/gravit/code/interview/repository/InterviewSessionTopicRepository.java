package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewSessionTopic;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewSessionTopicRepository extends JpaRepository<InterviewSessionTopic, Long> {
}
