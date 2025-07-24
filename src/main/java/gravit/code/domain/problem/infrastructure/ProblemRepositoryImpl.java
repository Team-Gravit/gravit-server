package gravit.code.domain.problem.infrastructure;

import gravit.code.domain.problem.dto.response.ProblemInfo;
import gravit.code.domain.problem.domain.Problem;
import gravit.code.domain.problem.domain.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ProblemRepositoryImpl implements ProblemRepository {

    private final ProblemJpaRepository problemJpaRepository;

    @Override
    public List<ProblemInfo> findAllProblemsByLessonId(@Param("lessonId") Long lessonId){
        return problemJpaRepository.findAllProblemsByLessonId(lessonId);
    }

    @Override
    public Problem save(Problem problem) {
        return problemJpaRepository.save(problem);
    }
}
