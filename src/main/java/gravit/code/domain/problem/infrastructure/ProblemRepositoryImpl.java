package gravit.code.domain.problem.infrastructure;

import gravit.code.domain.lesson.dto.response.LessonResponse;
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
    public List<LessonResponse> findByLessonId(@Param("lessonId") Long lessonId){
        return problemJpaRepository.findByLessonId(lessonId);
    }
}
