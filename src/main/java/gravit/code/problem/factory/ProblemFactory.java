package gravit.code.problem.factory;

import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.answer.service.AnswerQueryService;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.service.OptionQueryService;
import gravit.code.problem.dto.response.ProblemDetailResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class ProblemFactory {

    private final AnswerQueryService answerQueryService;
    private final OptionQueryService optionQueryService;

    public List<ProblemResponse> create(List<ProblemDetailResponse> problemDetailResponses) {
        Map<Long, AnswerResponse> answerMap = answerQueryService.getAnswersInProblem(problemDetailResponses);
        Map<Long, List<OptionResponse>> optionMap = optionQueryService.getOptionsInProblem(problemDetailResponses);

        return problemDetailResponses.stream()
                .map(detail -> create(detail, answerMap, optionMap))
                .toList();
    }

    private ProblemResponse create(
            ProblemDetailResponse detail,
            Map<Long, AnswerResponse> answerMap,
            Map<Long, List<OptionResponse>> optionMap
    ) {
        return switch (detail.problemType()) {
            case SUBJECTIVE -> createSubjective(detail, answerMap);
            case OBJECTIVE  -> createObjective(detail, optionMap);
        };
    }

    private ProblemResponse createSubjective(
            ProblemDetailResponse detail,
            Map<Long, AnswerResponse> answerMap
    ) {
        AnswerResponse answer = answerMap.get(detail.id());

        if (answer == null)
            throw new RestApiException(CustomErrorCode.ANSWER_NOT_FOUND);

        return ProblemResponse.createSubjectiveProblem(detail, answer);
    }

    private ProblemResponse createObjective(
            ProblemDetailResponse detail,
            Map<Long, List<OptionResponse>> optionMap
    ) {
        List<OptionResponse> options = optionMap.get(detail.id());

        if (options == null || options.isEmpty())
            throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

        return ProblemResponse.createObjectiveProblem(detail, options);
    }
}
