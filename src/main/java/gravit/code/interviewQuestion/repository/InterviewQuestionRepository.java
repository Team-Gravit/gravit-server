package gravit.code.interviewQuestion.repository;

import gravit.code.interviewQuestion.domain.InterviewQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewQuestionRepository extends JpaRepository<InterviewQuestion, Long> {
}
