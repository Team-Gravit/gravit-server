package gravit.code.problem.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemSubmission;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.internal.ProblemTypeDto;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import gravit.code.wrongAnsweredNote.service.WrongAnsweredNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProblemSubmissionCommandService {

    private final WrongAnsweredNoteService wrongAnsweredNoteService;

    private final ProblemSubmissionRepository problemSubmissionRepository;
    private final ProblemRepository problemRepository;

    @Transactional
    public void saveProblemSubmissions(
            long userId,
            List<ProblemSubmissionRequest> requests
    ) {
        List<Long> problemIds = requests.stream()
                .map(ProblemSubmissionRequest::problemId)
                .toList();

        Map<Long, ProblemType> problemTypes = findProblemTypes(problemIds);
        requests.forEach(request -> validateSubmission(request, problemTypes));

        List<ProblemSubmission> problemSubmissions = requests.stream()
                .map(request -> createProblemSubmission(userId, request))
                .toList();

        problemSubmissionRepository.saveAll(problemSubmissions);
    }

    @Transactional
    public void saveProblemSubmission(
            long userId,
            ProblemSubmissionRequest request
    ) {
        Map<Long, ProblemType> problemTypes = findProblemTypes(List.of(request.problemId()));
        validateSubmission(request, problemTypes);

        problemSubmissionRepository.save(createProblemSubmission(userId, request));
    }

    private ProblemSubmission createProblemSubmission(
            long userId,
            ProblemSubmissionRequest request
    ) {
        if (!request.isCorrect())
            wrongAnsweredNoteService.saveWrongAnsweredNote(userId, request.problemId());

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
            ProblemSubmissionRequest request,
            Map<Long, ProblemType> problemTypes
    ) {
        ProblemType problemType = problemTypes.get(request.problemId());

        if (problemType == null)
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        validateSubmissionContent(problemType, request);
    }

    private void validateSubmissionContent(
            ProblemType problemType,
            ProblemSubmissionRequest request
    ) {
        if (problemType == ProblemType.OBJECTIVE && request.selectedOptionId() == null)
            throw new RestApiException(CustomErrorCode.PROBLEM_TYPE_MISMATCH);

        if (problemType == ProblemType.SUBJECTIVE && (request.submittedContent() == null || request.submittedContent().isBlank()))
            throw new RestApiException(CustomErrorCode.PROBLEM_TYPE_MISMATCH);
    }
}
