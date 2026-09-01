package gravit.code.interviewQuestion.service;

import gravit.code.interview.domain.InterviewMode;
import gravit.code.interviewQuestion.repository.InterviewCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InterviewCategoryQueryService {

    private final InterviewCategoryRepository interviewCategoryRepository;

    public List<Long> getCategoryIds(InterviewMode mode) {
        return interviewCategoryRepository.findIdsByMode(mode);
    }
}
