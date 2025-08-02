package gravit.code.domain.problem.service;

import gravit.code.domain.problem.domain.ProblemRepository;
import gravit.code.domain.problem.dto.response.ProblemResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final ProblemRepository problemRepository;

    public List<ProblemResponse> getAllProblem(Long lessonsId){
        List<ProblemResponse> problems = problemRepository.findAllProblemByLessonId(lessonsId);

        if(problems.isEmpty())
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        return problems;
    }
}
