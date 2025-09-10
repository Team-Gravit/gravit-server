package gravit.code.domain.learning.service;

import gravit.code.domain.learning.domain.OptionRepository;
import gravit.code.domain.learning.domain.Problem;
import gravit.code.domain.learning.domain.ProblemRepository;
import gravit.code.domain.learning.domain.ProblemType;
import gravit.code.domain.learning.dto.response.OptionResponse;
import gravit.code.domain.learning.dto.response.ProblemResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final ProblemRepository problemRepository;
    private final OptionRepository optionRepository;

    public List<ProblemResponse> getAllProblem(Long lessonId){

        // 문제 조회, 선지 포함 X
        List<Problem> problems = problemRepository.findAllProblemByLessonId(lessonId);

        if(problems.isEmpty())
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        // 선지 조회, 객관식 문제에 대해서만 선지를 조회
        Map<Long, List<OptionResponse>> optionResponseMap = optionRepository
                .findAllByProblemIdInIds(problems.stream()
                        .filter(problem -> problem.getProblemType().equals(ProblemType.OBJECTIVE))
                        .map(Problem::getId).toList()
                )
                .stream()
                .collect(Collectors.groupingBy(OptionResponse::problemId));

        if(optionResponseMap.isEmpty())
            throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

        // 문제 + 선지 조합해서 반환
        return problems.stream()
                .map(problem -> ProblemResponse.create(
                        problem,
                        optionResponseMap.getOrDefault(problem.getId(), List.of())
                ))
                .toList();
    }
}
