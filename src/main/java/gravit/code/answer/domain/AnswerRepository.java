package gravit.code.answer.domain;

import gravit.code.answer.dto.response.AnswerResponse;

import java.util.Optional;

public interface AnswerRepository {
    Optional<AnswerResponse> findByProblemId(long id);
    void deleteByProblemId(long problemId);
}
