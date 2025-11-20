package gravit.code.learning.domain;

import gravit.code.learning.dto.response.AnswerResponse;

import java.util.Optional;

public interface AnswerRepository {
    Optional<AnswerResponse> findByProblemId(long id);
    void deleteByProblemId(long problemId);
}
