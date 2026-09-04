package gravit.code.interviewQuestion.repository;

import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterviewQuestionConceptRepository extends JpaRepository<InterviewQuestionConcept, Long> {
}
