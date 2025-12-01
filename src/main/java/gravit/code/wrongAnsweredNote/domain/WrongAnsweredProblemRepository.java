package gravit.code.wrongAnsweredNote.domain;

import gravit.code.problem.dto.response.ProblemDetail;

import java.util.List;
import java.util.Optional;

public interface WrongAnsweredProblemRepository {
    Optional<WrongAnsweredNote> findByProblemIdAndUserId(
            long problemId,
            long userId
    );
    List<ProblemDetail> findWrongAnsweredProblemDetailByUnitIdAndUserId(
            long unitId,
            long userId
    );
    void save(WrongAnsweredNote wrongAnsweredNote);
    void deleteByProblemIdAndUserId(
            long problemId,
            long userId
    );
    int countByUnitIdAndUserId(
            long unitId,
            long userId
    );
}
