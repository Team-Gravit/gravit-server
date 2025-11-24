package gravit.code.admin.service;

import gravit.code.admin.dto.request.OptionCreateRequest;
import gravit.code.admin.dto.request.OptionUpdateRequest;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.domain.Option;
import gravit.code.option.domain.OptionRepository;
import gravit.code.problem.domain.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminOptionService {

    private final OptionRepository optionRepository;
    private final ProblemRepository problemRepository;

    @Transactional
    public void createOption(OptionCreateRequest request){
        if(!problemRepository.existsProblemById(request.problemId()))
            throw new RestApiException(CustomErrorCode.PROBLEM_NOT_FOUND);

        Option option = Option.create(request.content(), request.explanation(), request.isAnswer(), request.problemId());
        optionRepository.save(option);
    }

    @Transactional
    public void updateOption(OptionUpdateRequest request){
        Option option = optionRepository.findById(request.optionId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.OPTION_NOT_FOUND));

        option.updateOption(request);
    }

    @Transactional
    public void deleteOption(Long optionId){
        if(!optionRepository.existsById(optionId))
            throw new RestApiException(CustomErrorCode.OPTION_NOT_FOUND);

        optionRepository.deleteById(optionId);
    }
}
