package gravit.code.problem.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemSubmissionRepository;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProblemSubmissionService {

    private final ProblemSubmissionRepository problemSubmissionRepository;

    @Transactional
    public void saveProblemSubmission(
            long userId,
            List<ProblemSubmissionRequest> requests,
            boolean isFirstTry
    ){
        List<ProblemSubmission> problemSubmissions;
        if(isFirstTry){
            problemSubmissions = createProblemSubmission(userId, requests);
        }else{
            problemSubmissions = updateProblemSubmission(userId, requests);
        }

        problemSubmissionRepository.saveAll(problemSubmissions);
    }

    private List<ProblemSubmission> updateProblemSubmission(
            long userId,
            List<ProblemSubmissionRequest> requests
    ){
        Map<Long, Boolean> problemSubmissionMap = requests.stream()
                        .collect(Collectors.toMap(
                                ProblemSubmissionRequest::problemId,
                                ProblemSubmissionRequest::isCorrect
                        ));

        List<Long> problemIds = requests.stream()
                .map(ProblemSubmissionRequest::problemId)
                .toList();

        List<ProblemSubmission> problemSubmissions = problemSubmissionRepository.findByIdInIdsAndUserId(problemIds, userId);

        if(problemSubmissions.size() != requests.size())
            throw new RestApiException(CustomErrorCode.PROBLEM_SUBMISSION_NOT_FOUND);

        problemSubmissions.forEach(problemSubmission -> {
            long problemId = problemSubmission.getProblemId();
            boolean isCorrect = problemSubmissionMap.get(problemId);

            problemSubmission.updateIsCorrect(isCorrect);
        });

        return problemSubmissions;
    }

    private List<ProblemSubmission> createProblemSubmission(
            long userId,
            List<ProblemSubmissionRequest> requests
    ){

        return requests.stream()
                .map(problemSubmissionRequest ->
                        ProblemSubmission.create(problemSubmissionRequest.isCorrect(),problemSubmissionRequest.problemId(), userId)
                ).toList();
    }
}
