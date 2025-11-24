package gravit.code.answer.infrastructure;

import gravit.code.answer.domain.AnswerRepository;
import gravit.code.answer.dto.response.AnswerResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class AnswerRepositoryImpl implements AnswerRepository {

    private final AnswerJpaRepository answerJpaRepository;

    @Override
    public Optional<AnswerResponse> findByProblemId(long problemId) {
        return answerJpaRepository.findByProblemId(problemId);
    }

    @Override
    public void deleteByProblemId(long problemId) {
        answerJpaRepository.deleteById(problemId);
    }
}
