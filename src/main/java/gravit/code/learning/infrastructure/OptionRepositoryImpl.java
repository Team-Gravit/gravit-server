package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Option;
import gravit.code.learning.domain.OptionRepository;
import gravit.code.learning.dto.response.OptionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class OptionRepositoryImpl implements OptionRepository {

    private final OptionJpaRepository optionJpaRepository;

    @Override
    public Option save(Option option) {
        return optionJpaRepository.save(option);
    }

    @Override
    public List<Option> saveAll(List<Option> options) {
        return optionJpaRepository.saveAll(options);
    }

    @Override
    public List<OptionResponse> findAllByProblemIdInIds(List<Long> problemIds){
        return optionJpaRepository.findAllByProblemIdInIds(problemIds);
    }

    @Override
    public List<OptionResponse> findByProblemId(Long problemId){
        return optionJpaRepository.findByProblemId(problemId);
    }

    @Override
    public Optional<Option> findById(Long optionId){
        return optionJpaRepository.findById(optionId);
    }

    @Override
    public void deleteById(Long optionId){
        optionJpaRepository.deleteById(optionId);
    }

    @Override
    public void deleteAllByProblemId(Long problemId){
        optionJpaRepository.deleteAllByProblemId(problemId);
    }

    @Override
    public boolean existsById(Long optionId){
        return optionJpaRepository.existsById(optionId);
    }
}
