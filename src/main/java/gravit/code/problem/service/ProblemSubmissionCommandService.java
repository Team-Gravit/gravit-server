package gravit.code.problem.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.internal.ProblemTypeDto;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProblemSubmissionCommandService {

    private final ProblemSubmissionRepository problemSubmissionRepository;
    private final ProblemRepository problemRepository;

    @Transactional(readOnly = true)
    public void validateProblemSubmissions(List<ProblemSubmissionSaveRequest> requests) {
        List<Long> problemIds = requests.stream()
                .map(ProblemSubmissionSaveRequest::problemId)
                .toList();

        Map<Long, ProblemType> problemTypes = findProblemTypes(problemIds);

        requests.forEach(request -> validateSubmission(request, problemTypes));
    }

    @Transactional
    public List<Long> saveProblemSubmissions(
            long userId,
            List<ProblemSubmissionSaveRequest> requests
    ) {
        List<ProblemSubmission> problemSubmissions = requests.stream()
                .map(request -> createProblemSubmission(userId, request))
                .toList();

        problemSubmissionRepository.saveAll(problemSubmissions);

        return requests.stream()
                .filter(request -> !request.isCorrect())
                .map(ProblemSubmissionSaveRequest::problemId)
                .toList();
    }

    private ProblemSubmission createProblemSubmission(
            long userId,
            ProblemSubmissionSaveRequest request
    ) {
        return ProblemSubmission.create(
                request.isCorrect(),
                request.problemId(),
                userId,
                request.selectedOptionId(),
                request.submittedContent()
        );
    }

    private Map<Long, ProblemType> findProblemTypes(List<Long> problemIds) {
        return problemRepository.findProblemTypesByIds(problemIds).stream()
                .collect(Collectors.toMap(
                        ProblemTypeDto::problemId,
                        ProblemTypeDto::problemType
                ));
    }

    private void validateSubmission(
            ProblemSubmissionSaveRequest request,
            Map<Long, ProblemType> problemTypes
    ) {
        ProblemType problemType = problemTypes.get(request.problemId());

        if (problemType == null)
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        validateSubmissionContent(problemType, request);
    }

    private void validateSubmissionContent(
            ProblemType problemType,
            ProblemSubmissionSaveRequest request
    ) {
        if (problemType == ProblemType.OBJECTIVE && request.selectedOptionId() == null)
            throw new RestApiException(CustomErrorCode.PROBLEM_TYPE_MISMATCH);

        if (problemType == ProblemType.SUBJECTIVE && (request.submittedContent() == null || request.submittedContent().isBlank()))
            throw new RestApiException(CustomErrorCode.PROBLEM_TYPE_MISMATCH);
    }
}
