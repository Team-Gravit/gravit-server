package gravit.code.problem.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.internal.ProblemSubmissionRow;
import gravit.code.problem.dto.internal.ProblemTypeDto;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProblemSubmissionCommandService {

    private final ProblemSubmissionRepository problemSubmissionRepository;
    private final ProblemRepository problemRepository;

    private final ObjectMapper objectMapper;
    private final Clock clock;

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
        problemSubmissionRepository.insertAll(userId, toPayload(requests), LocalDateTime.now(clock));

        return requests.stream()
                .filter(request -> !request.isCorrect())
                .map(ProblemSubmissionSaveRequest::problemId)
                .toList();
    }

    private String toPayload(List<ProblemSubmissionSaveRequest> requests) {
        List<ProblemSubmissionRow> rows = requests.stream()
                .map(ProblemSubmissionRow::from)
                .toList();

        try {
            return objectMapper.writeValueAsString(rows);
        } catch (JsonProcessingException e) {
            throw new RestApiException(CustomErrorCode.PROBLEM_SUBMISSION_SERIALIZE_FAILED);
        }
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
