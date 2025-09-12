package gravit.code.progress.infrastructure;

import gravit.code.progress.domain.ProblemProgress;
import gravit.code.progress.domain.ProblemProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ProblemProgressRepositoryImpl implements ProblemProgressRepository {

    private final ProblemProgressJpaRepository problemProgressJpaRepository;

    @Override
    public List<ProblemProgress> saveAll(List<ProblemProgress> problemProgresses){
        return problemProgressJpaRepository.saveAll(problemProgresses);
    }
}
