package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.dto.response.ProblemResponse;
import gravit.code.domain.learning.domain.Problem;
import gravit.code.domain.learning.domain.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ProblemRepositoryImpl implements ProblemRepository {

    private final ProblemJpaRepository problemJpaRepository;

    @Override
    public Problem save(Problem problem) {
        return problemJpaRepository.save(problem);
    }

    @Override
    public List<ProblemResponse> findAllProblemByLessonId(@Param("lessonId") Long lessonId){
        return problemJpaRepository.findAllProblemByLessonId(lessonId);
    }

}
