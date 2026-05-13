package gravit.code.problem.service;

import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.repository.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemQueryService {

    private final ProblemRepository problemRepository;

    @Transactional(readOnly = true)
    public List<ProblemDetailResponse> getAllProblemInLesson(
        long userId,
        long lessonId
    ){
        return problemRepository.findAllProblemDetailByLessonIdAndUserId(lessonId, userId);
    }
}
