package gravit.code.domain.learning.service;

import gravit.code.domain.learning.domain.ProblemRepository;
import gravit.code.domain.learning.dto.response.ProblemResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final ProblemRepository problemRepository;

    public List<ProblemResponse> getAllProblem(Long lessonId){
        List<ProblemResponse> problems = problemRepository.findAllProblemByLessonId(lessonId);

        if(problems.isEmpty())
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        return problems;
    }
}
