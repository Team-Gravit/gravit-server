package gravit.code.interviewTechStack.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interviewTechStack.domain.InterviewJobRole;
import gravit.code.interviewTechStack.dto.response.InterviewTechStackResponse;
import gravit.code.interviewTechStack.repository.InterviewStackAxisRepository;
import gravit.code.interviewTechStack.repository.InterviewTechStackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InterviewTechStackQueryService {

    private final InterviewTechStackRepository interviewTechStackRepository;
    private final InterviewStackAxisRepository interviewStackAxisRepository;

    public List<InterviewTechStackResponse> getTechStacks(InterviewJobRole jobRole) {
        return interviewTechStackRepository.findAllByJobRole(jobRole);
    }

    public List<Long> getCategoryIdsByTechStack(long techStackId) {
        if (!interviewTechStackRepository.existsById(techStackId)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_TECH_STACK_NOT_FOUND);
        }

        return interviewStackAxisRepository.findCategoryIdsByTechStackId(techStackId);
    }
}
