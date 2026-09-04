package gravit.code.interviewQuestion.repository;

import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface InterviewQuestionConceptRepository extends JpaRepository<InterviewQuestionConcept, Long> {

    @Query("""
            SELECT c FROM InterviewQuestionConcept c
            WHERE c.questionId IN :questionIds
            ORDER BY c.questionId ASC, c.displayOrder ASC
    """)
    List<InterviewQuestionConcept> findAllByQuestionIds(@Param("questionIds") Collection<Long> questionIds);
}
