package gravit.code.admin.service;

import gravit.code.admin.dto.request.ProblemCreateRequest;
import gravit.code.admin.dto.request.ProblemUpdateRequest;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.*;
import gravit.code.learning.dto.response.OptionResponse;
import gravit.code.learning.dto.response.ProblemResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminProblemService {

    private final ProblemRepository problemRepository;
    private final OptionRepository optionRepository;

    @Transactional
    public void createProblem(ProblemCreateRequest request){
        Problem problem = Problem.create(ProblemType.from(request.problemType()), request.question(), request.content(), request.answer(), request.lessonId());

        Long problemId = problemRepository.save(problem).getId();

        if(ProblemType.from(request.problemType()).equals(ProblemType.OBJECTIVE)){
            List<Option> options = request.options().stream()
                    .map(option -> Option.create(option.content(), option.explanation(), option.isAnswer(), problemId))
                    .toList();

            optionRepository.saveAll(options);
        }
    }

    @Transactional(readOnly = true)
    public ProblemResponse getProblem(Long problemId){
        Problem problem = problemRepository.findById(problemId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

        List<OptionResponse> options = optionRepository.findByProblemId(problemId);

        return ProblemResponse.create(problem, options);
    }

    @Transactional
    public void updateProblem(ProblemUpdateRequest request){
        Problem problem = problemRepository.findById(request.problemId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND));

        problem.updateProblem(request);
    }

    @Transactional
    public void deleteProblem(Long problemId){
        problemRepository.deleteById(problemId);
        optionRepository.deleteAllByProblemId(problemId);
    }
}
