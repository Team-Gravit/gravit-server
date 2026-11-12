package gravit.code.problem.factory;

import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.answer.service.AnswerQueryService;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.service.OptionQueryService;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.OPTION_NOT_FOUND;

@Component
@RequiredArgsConstructor
public class ProblemFactory {

    private final AnswerQueryService answerQueryService;
    private final OptionQueryService optionQueryService;

    public List<ProblemResponse> create(List<ProblemDetailResponse> problemDetailResponses) {
        Map<Long, AnswerResponse> problemIdToAnswer = answerQueryService.getAnswersInProblem(problemDetailResponses);
        Map<Long, List<OptionResponse>> problemIdToOptions = optionQueryService.getOptionsInProblem(problemDetailResponses);

        return problemDetailResponses.stream()
                .map(detail -> create(detail, problemIdToAnswer, problemIdToOptions))
                .toList();
    }

    private ProblemResponse create(
            ProblemDetailResponse detail,
            Map<Long, AnswerResponse> problemIdToAnswer,
            Map<Long, List<OptionResponse>> problemIdToOptions
    ) {
        return switch (detail.problemType()) {
            case SUBJECTIVE -> createSubjective(detail, problemIdToAnswer);
            case OBJECTIVE  -> createObjective(detail, problemIdToOptions);
        };
    }

    private ProblemResponse createSubjective(
            ProblemDetailResponse detail,
            Map<Long, AnswerResponse> problemIdToAnswer
    ) {
        AnswerResponse answer = problemIdToAnswer.get(detail.id());

        if (answer == null)
            throw new RestApiException(ANSWER_NOT_FOUND);

        return ProblemResponse.createSubjectiveProblem(detail, answer);
    }

    private ProblemResponse createObjective(
            ProblemDetailResponse detail,
            Map<Long, List<OptionResponse>> problemIdToOptions
    ) {
        List<OptionResponse> options = problemIdToOptions.get(detail.id());

        if (options == null || options.isEmpty())
            throw new RestApiException(OPTION_NOT_FOUND);

        return ProblemResponse.createObjectiveProblem(detail, options);
    }
}
