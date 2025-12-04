package gravit.code.option.infrastructure;

import gravit.code.option.domain.Option;
import gravit.code.option.domain.OptionRepository;
import gravit.code.option.dto.response.OptionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class OptionRepositoryImpl implements OptionRepository {

    private final OptionJpaRepository optionJpaRepository;

    @Override
    public List<OptionResponse> findByProblemId(long problemId){
        return optionJpaRepository.findByProblemId(problemId);
    }

    @Override
    public Optional<Option> findById(long optionId){
        return optionJpaRepository.findById(optionId);
    }

    @Override
    public boolean existsById(long optionId){
        return optionJpaRepository.existsById(optionId);
    }

    @Override
    public Option save(Option option) {
        return optionJpaRepository.save(option);
    }

    @Override
    public List<Option> saveAll(List<Option> options) {
        return optionJpaRepository.saveAll(options);
    }

    @Override
    public void deleteById(long optionId){
        optionJpaRepository.deleteById(optionId);
    }

    @Override
    public void deleteAllByProblemId(long problemId){
        optionJpaRepository.deleteAllByProblemId(problemId);
    }
}
