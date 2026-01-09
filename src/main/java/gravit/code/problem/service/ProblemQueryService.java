package gravit.code.problem.service;

import gravit.code.answer.domain.AnswerRepository;
import gravit.code.answer.dto.response.AnswerResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.domain.OptionRepository;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.problem.domain.ProblemRepository;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemDetail;
import gravit.code.problem.dto.response.ProblemResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemQueryService {

    private final ProblemRepository problemRepository;
    private final AnswerRepository answerRepository;
    private final OptionRepository optionRepository;

    @Transactional(readOnly = true)
    public List<ProblemDetail> getAllProblemInLesson(
        long userId,
        long lessonId
    ){
        return problemRepository.findAllProblemDetailByLessonIdAndUserId(lessonId, userId);
    }

    @Transactional(readOnly = true)
    public List<ProblemResponse> getAnswerOrOptionInProblems(List<ProblemDetail> problemDetails){
        return problemDetails.stream()
                .map(problem -> {
                    if (problem.problemType() == ProblemType.SUBJECTIVE){
                        AnswerResponse answerResponse = answerRepository.findByProblemId(problem.id())
                                .orElseThrow(() -> new RestApiException(CustomErrorCode.ANSWER_NOT_FOUND));

                        return ProblemResponse.createSubjectiveProblem(problem, answerResponse);
                    }else{
                        List<OptionResponse> optionResponses = optionRepository.findByProblemId(problem.id());

                        if(optionResponses.isEmpty())
                            throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

                        return ProblemResponse.createObjectiveProblem(problem, optionResponses);
                    }
                }).toList();
    }
}
