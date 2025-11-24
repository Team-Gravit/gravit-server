package gravit.code.learning.domain;

import gravit.code.learning.dto.response.OptionResponse;

import java.util.List;
import java.util.Optional;

public interface OptionRepository {
    List<OptionResponse> findByProblemId(long problemId);
    Optional<Option> findById(long optionId);
    boolean existsById(long optionId);
    Option save(Option option);
    List<Option> saveAll(List<Option> options);
    void deleteById(long optionId);
    void deleteAllByProblemId(long problemId);
}