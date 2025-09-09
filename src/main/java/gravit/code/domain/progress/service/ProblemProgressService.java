package gravit.code.domain.progress.service;

import gravit.code.domain.learning.dto.request.ProblemResultRequest;
import gravit.code.domain.progress.domain.ProblemProgress;
import gravit.code.domain.progress.domain.ProblemProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemProgressService {

    private final ProblemProgressRepository problemProgressRepository;

    public void saveProblemResults(Long userId, List<ProblemResultRequest> request){
        List<ProblemProgress> problemProgresses = request.stream()
                .map(problemResult ->
                        ProblemProgress.create(problemResult.isCorrect(), problemResult.incorrectCounts(), userId, problemResult.problemId())
                ).toList();

        problemProgressRepository.saveAll(problemProgresses);
    }
}
