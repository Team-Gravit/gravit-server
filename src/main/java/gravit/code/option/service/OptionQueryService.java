package gravit.code.option.service;

import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OptionQueryService {

    private final OptionRepository optionRepository;

    public Map<Long, List<OptionResponse>> getOptionsInProblem(List<ProblemDetailResponse> problemDetailResponses) {
        List<ProblemDetailResponse> objectiveProblems = problemDetailResponses.stream()
                .filter(p -> p.problemType() == ProblemType.OBJECTIVE)
                .toList();

        Map<Long, List<OptionResponse>> optionMap;
        if(!objectiveProblems.isEmpty()){
            List<Long> objectiveProblemIds = objectiveProblems.stream()
                    .map(ProblemDetailResponse::id)
                    .toList();

            List<OptionResponse> optionResponses = optionRepository.findAllByProblemIdIn(objectiveProblemIds);

            optionMap = optionResponses.stream()
                    .collect(Collectors.groupingBy(OptionResponse::problemId));
        } else {
            optionMap = new HashMap<>();
        }
        return optionMap;
    }
}
