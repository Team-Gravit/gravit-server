package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Learning;
import gravit.code.learning.domain.LearningRepository;
import gravit.code.learning.dto.response.LearningDetail;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class LearningRepositoryImpl implements LearningRepository {

    private final LearningJpaRepository learningJpaRepository;

    @Override
    public Optional<Learning> findByUserId(long userId){
        return learningJpaRepository.findByUserId(userId);
    }

    @Override
    public List<Learning> findAll(Pageable pageable){
        return learningJpaRepository.findAll(pageable).getContent();
    }

    @Override
    public Optional<LearningDetail> findLearningDetailByUserId(long userId) {
        return learningJpaRepository.findLearningDetailByUserId(userId);
    }

    @Override
    public Learning save(Learning learning){
        return learningJpaRepository.save(learning);
    }

    @Override
    public void saveAll(List<Learning> learnings){
        learningJpaRepository.saveAll(learnings);
    }
}
