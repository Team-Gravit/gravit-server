package gravit.code.answer.repository;

import gravit.code.answer.domain.Answer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AnswerRepository extends JpaRepository<Answer,Long> {

    void deleteByProblemId(long problemId);

    Optional<Answer> findByProblemId(long problemId);

    @Query("""
            SELECT a
            FROM Answer a
            WHERE a.problemId IN :problemIds
            ORDER BY a.problemId ASC
    """)
    List<Answer> findByProblemIdIn(@Param("problemIds") List<Long> problemIds);
}
