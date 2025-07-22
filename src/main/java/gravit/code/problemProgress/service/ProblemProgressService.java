package gravit.code.problemProgress.service;

import gravit.code.problem.dto.request.ProblemResult;
import gravit.code.problemProgress.domain.ProblemProgress;
import gravit.code.problemProgress.repository.ProblemProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemProgressService {

    private final ProblemProgressRepository problemProgressRepository;

    public void saveProblemResults(Long userId, List<ProblemResult> problemResults){
        List<ProblemProgress> problemProgresses = problemResults.stream()
                .map(problemResult ->
                        ProblemProgress.create(problemResult.isCorrect(), problemResult.incorrectCounts(), userId, problemResult.problemId())
                ).toList();

        problemProgressRepository.saveAll(problemProgresses);
    }
}
