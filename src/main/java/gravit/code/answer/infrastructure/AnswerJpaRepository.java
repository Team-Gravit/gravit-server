package gravit.code.answer.infrastructure;

import gravit.code.answer.domain.Answer;
import gravit.code.answer.dto.response.AnswerResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface AnswerJpaRepository extends JpaRepository<Answer,Long> {
    @Query("""
        SELECT new gravit.code.answer.dto.response.AnswerResponse(a.content, a.explanation)
        FROM Answer a
        WHERE a.problemId = :problemId
    """)
    Optional<AnswerResponse> findByProblemId(@Param("problemId") long problemId);
}
