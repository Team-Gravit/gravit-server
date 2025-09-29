package gravit.code.learning.domain;

import gravit.code.learning.dto.response.OptionResponse;

import java.util.List;
import java.util.Optional;

public interface OptionRepository {
    Option save(Option option);
    List<Option> saveAll(List<Option> options);
    List<OptionResponse> findAllByProblemIdInIds(List<Long> problemIds);
    List<OptionResponse> findByProblemId(Long problemId);
    Optional<Option> findById(Long optionId);
    void deleteById(Long optionId);
    void deleteAllByProblemId(Long problemId);
    boolean existsById(Long optionId);
}