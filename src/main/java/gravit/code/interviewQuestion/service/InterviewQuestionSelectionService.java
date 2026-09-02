package gravit.code.interviewQuestion.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interviewQuestion.domain.InterviewDifficultyQuota;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolItem;
import gravit.code.interviewQuestion.dto.internal.SelectedInterviewQuestion;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.interviewQuestion.support.InterviewQuestionSelector;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InterviewQuestionSelectionService {

    private final InterviewQuestionRepository interviewQuestionRepository;

    public List<SelectedInterviewQuestion> selectQuestions(
            List<Long> categoryIds,
            InterviewLevel level,
            boolean coverAllCategories
    ) {
        if (categoryIds.isEmpty()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }

        List<InterviewQuestionPoolItem> pool = interviewQuestionRepository.findPoolByCategoryIds(categoryIds);
        List<Long> requiredCategoryIds = coverAllCategories ? categoryIds : List.of();

        List<Long> selectedQuestionIds = InterviewQuestionSelector.select(
                pool,
                requiredCategoryIds,
                InterviewDifficultyQuota.from(level)
        );

        return orderBySelection(selectedQuestionIds, interviewQuestionRepository.findContentsByIds(selectedQuestionIds));
    }

    private List<SelectedInterviewQuestion> orderBySelection(
            List<Long> selectedQuestionIds,
            List<SelectedInterviewQuestion> questions
    ) {
        Map<Long, SelectedInterviewQuestion> questionById = questions.stream()
                .collect(Collectors.toMap(SelectedInterviewQuestion::questionId, Function.identity()));

        return selectedQuestionIds.stream()
                .map(questionById::get)
                .toList();
    }
}
