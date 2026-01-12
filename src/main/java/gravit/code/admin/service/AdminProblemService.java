package gravit.code.admin.service;

import gravit.code.admin.dto.request.ProblemCreateRequest;
import gravit.code.admin.dto.request.ProblemUpdateRequest;
import gravit.code.answer.domain.Answer;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.dto.response.OptionResponse;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.repository.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminProblemService {

    private final ProblemRepository problemRepository;
    private final OptionRepository optionRepository;
    private final AnswerRepository answerRepository;

    @Transactional
    public void createProblem(ProblemCreateRequest request){
        Problem problem = Problem.create(ProblemType.from(request.problemType()), request.instruction(), request.content(), request.lessonId());

        problemRepository.save(problem);
    }

    @Transactional(readOnly = true)
    public ProblemResponse getProblem(long problemId){
        Problem problem = problemRepository.findById(problemId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

        if(problem.getProblemType() == ProblemType.OBJECTIVE){
            List<OptionResponse> options = optionRepository.findByProblemId(problemId);

            if(options.isEmpty())
                throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

            return ProblemResponse.createObjectiveProblemForAdmin(problem, options);
        }else{
            Answer answer = answerRepository.findByProblemId(problemId)
                    .orElseThrow(() -> new RestApiException(CustomErrorCode.ANSWER_NOT_FOUND));

            return ProblemResponse.createSubjectiveProblemForAdmin(problem, answer);
        }
    }

    @Transactional
    public void updateProblem(ProblemUpdateRequest request){
        Problem problem = problemRepository.findById(request.problemId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

        problem.updateProblem(request);
    }

    @Transactional
    public void deleteProblem(long problemId){

        if(!problemRepository.existsProblemById(problemId))
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        problemRepository.deleteById(problemId);
        optionRepository.deleteAllByProblemId(problemId);
        answerRepository.deleteByProblemId(problemId);
    }
}
