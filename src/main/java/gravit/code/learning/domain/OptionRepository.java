package gravit.code.learning.domain;

import gravit.code.learning.dto.response.OptionResponse;

import java.util.List;

public interface OptionRepository {
    Option save(Option option);
    List<OptionResponse> findAllByProblemIdInIds(List<Long> problemIds);
}