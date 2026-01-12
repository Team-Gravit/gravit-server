package gravit.code.answer.repository;

import gravit.code.answer.domain.Answer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AnswerRepository extends JpaRepository<Answer,Long> {

    void deleteByProblemId(long problemId);

    Optional<Answer> findByProblemId(long problemId);

}
