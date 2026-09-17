package gravit.code.admin.service;

import gravit.code.admin.dto.request.ObjectiveOptionUpdateRequest;
import gravit.code.admin.dto.request.ObjectiveProblemUpdateRequest;
import gravit.code.admin.dto.request.SubjectiveAnswerUpdateRequest;
import gravit.code.admin.dto.request.SubjectiveProblemUpdateRequest;
import gravit.code.admin.dto.response.ProblemDetailResponse;
import gravit.code.answer.domain.Answer;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.domain.Option;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.OBJECTIVE_OPTIONS_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.OPTION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.OPTION_NOT_IN_PROBLEM;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_TYPE_MISMATCH;

@Service
@RequiredArgsConstructor
public class AdminProblemService {

    private static final int OBJECTIVE_OPTION_COUNT = 4;

    private final ProblemRepository problemRepository;
    private final OptionRepository optionRepository;
    private final AnswerRepository answerRepository;

    @Transactional(readOnly = true)
    public ProblemDetailResponse getProblem(long problemId) {
        Problem problem = problemRepository.findById(problemId)
                .orElseThrow(() -> new RestApiException(PROBLEM_NOT_FOUND));

        if (problem.getProblemType() == ProblemType.OBJECTIVE) {
            List<Option> options = optionRepository.findByProblemIdOrderById(problemId);

            if (options.isEmpty()) {
                throw new RestApiException(OPTION_NOT_FOUND);
            }

            return ProblemDetailResponse.objective(problem, options);
        }

        Answer answer = answerRepository.findByProblemId(problemId)
                .orElseThrow(() -> new RestApiException(ANSWER_NOT_FOUND));

        return ProblemDetailResponse.subjective(problem, answer);
    }

    @Transactional
    public void updateObjective(
            long problemId,
            ObjectiveProblemUpdateRequest request
    ) {
        Problem problem = problemRepository.findById(problemId)
                .orElseThrow(() -> new RestApiException(PROBLEM_NOT_FOUND));

        if (problem.getProblemType() != ProblemType.OBJECTIVE) {
            throw new RestApiException(PROBLEM_TYPE_MISMATCH);
        }

        String instruction = request.instruction() != null ? request.instruction() : problem.getInstruction();
        String content = request.content() != null ? request.content() : problem.getContent();

        problem.updateContent(instruction, content);

        if (request.options() != null) {
            replaceOptions(problemId, request.options());
        }
    }

    @Transactional
    public void updateSubjective(
            long problemId,
            SubjectiveProblemUpdateRequest request
    ) {
        Problem problem = problemRepository.findById(problemId)
                .orElseThrow(() -> new RestApiException(PROBLEM_NOT_FOUND));

        if (problem.getProblemType() != ProblemType.SUBJECTIVE) {
            throw new RestApiException(PROBLEM_TYPE_MISMATCH);
        }

        String instruction = request.instruction() != null ? request.instruction() : problem.getInstruction();
        String content = request.content() != null ? request.content() : problem.getContent();

        problem.updateContent(instruction, content);

        SubjectiveAnswerUpdateRequest answerRequest = request.answer();
        if (answerRequest != null) {
            Answer answer = answerRepository.findByProblemId(problemId)
                    .orElseThrow(() -> new RestApiException(ANSWER_NOT_FOUND));

            answer.update(answerRequest.content(), answerRequest.explanation());
        }
    }

    private void replaceOptions(
            long problemId,
            List<ObjectiveOptionUpdateRequest> options
    ) {
        validateObjectiveOptions(options);

        for (ObjectiveOptionUpdateRequest optionRequest : options) {
            Option option = optionRepository.findById(optionRequest.optionId())
                    .orElseThrow(() -> new RestApiException(OPTION_NOT_FOUND));

            if (option.getProblemId() != problemId) {
                throw new RestApiException(OPTION_NOT_IN_PROBLEM);
            }

            option.update(optionRequest.content(), optionRequest.explanation(), optionRequest.isAnswer());
        }
    }

    private void validateObjectiveOptions(List<ObjectiveOptionUpdateRequest> options) {
        long answerCount = options.stream()
                .filter(ObjectiveOptionUpdateRequest::isAnswer)
                .count();

        if (options.size() != OBJECTIVE_OPTION_COUNT || answerCount != 1) {
            throw new RestApiException(OBJECTIVE_OPTIONS_INVALID);
        }
    }
}
