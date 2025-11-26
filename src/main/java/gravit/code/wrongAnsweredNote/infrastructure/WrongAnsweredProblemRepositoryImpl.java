package gravit.code.wrongAnsweredNote.infrastructure;

import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredNote;
import gravit.code.wrongAnsweredNote.domain.WrongAnsweredProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class WrongAnsweredProblemRepositoryImpl implements WrongAnsweredProblemRepository {

    private final WrongAnsweredProblemJpaRepository wrongAnsweredProblemJpaRepository;

    @Override
    public List<ProblemDetail> findWrongAnsweredProblemDetailByUnitIdAndUserId(
            long unitId,
            long userId
    ) {
        return wrongAnsweredProblemJpaRepository.findWrongAnsweredProblemDetailByUnitIdAndUserId(unitId, userId);
    }

    @Override
    public Optional<WrongAnsweredNote> findByProblemIdAndUserId(
            long problemId,
            long userId
    ) {
        return wrongAnsweredProblemJpaRepository.findByProblemIdAndUserId(problemId, userId);
    }

    @Override
    public void save(WrongAnsweredNote wrongAnsweredNote) {
        wrongAnsweredProblemJpaRepository.save(wrongAnsweredNote);
    }

    @Override
    public void deleteByProblemIdAndUserId(
            long problemId,
            long userId
    ) {
        wrongAnsweredProblemJpaRepository.deleteByProblemIdAndUserId(problemId, userId);
    }
}
