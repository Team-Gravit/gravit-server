package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewSessionTopic;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface InterviewSessionTopicRepository extends JpaRepository<InterviewSessionTopic, Long> {

    List<InterviewSessionTopic> findAllBySessionIdIn(Collection<Long> sessionIds);
}
