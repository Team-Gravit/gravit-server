package gravit.code.learning.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.*;
import gravit.code.learning.dto.response.AnswerResponse;
import gravit.code.learning.dto.response.OptionResponse;
import gravit.code.learning.dto.response.ProblemResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemService {

    private final ProblemRepository problemRepository;
    private final AnswerRepository answerRepository;
    private final OptionRepository optionRepository;

    @Transactional(readOnly = true)
    public List<ProblemResponse> getAllProblemInLesson(long lessonId){

        List<Problem> problems = problemRepository.findAllProblemByLessonId(lessonId);

        return problems.stream()
                .map(problem -> {
                    if (problem.getProblemType() == ProblemType.SUBJECTIVE){
                        AnswerResponse answerResponse = answerRepository.findByProblemId(problem.getId())
                                .orElseThrow(() -> new RestApiException(CustomErrorCode.ANSWER_NOT_FOUND));

                        return ProblemResponse.createSubjectiveProblem(problem, answerResponse);
                    }else{
                        List<OptionResponse> optionResponses = optionRepository.findByProblemId(problem.getId());

                        if(optionResponses.isEmpty())
                            throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

                        return ProblemResponse.createObjectiveProblem(problem, optionResponses);
                    }
                }).toList();
    }
}
