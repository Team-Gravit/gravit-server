package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Option;
import gravit.code.domain.learning.domain.OptionRepository;
import gravit.code.domain.learning.dto.response.OptionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class OptionRepositoryImpl implements OptionRepository {

    private final OptionJpaRepository optionJpaRepository;

    @Override
    public Option save(Option option) {
        return optionJpaRepository.save(option);
    }

    @Override
    public List<OptionResponse> findAllByProblemIdInIds(List<Long> problemIds){
        return optionJpaRepository.findAllByProblemIdInIds(problemIds);
    }
}
