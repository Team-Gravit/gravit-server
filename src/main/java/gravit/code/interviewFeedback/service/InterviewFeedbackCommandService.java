package gravit.code.interviewFeedback.service;

import gravit.code.interviewFeedback.domain.InterviewFeedback;
import gravit.code.interviewFeedback.dto.internal.InterviewGradedAnswerDto;
import gravit.code.interviewFeedback.dto.internal.InterviewScoreDto;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewFeedbackCommandService {

    private final InterviewFeedbackRepository interviewFeedbackRepository;

    @Transactional
    public void saveAll(List<InterviewGradedAnswerDto> gradedAnswers) {
        List<InterviewFeedback> feedbacks = gradedAnswers.stream()
                .map(this::toFeedback)
                .toList();

        interviewFeedbackRepository.saveAll(feedbacks);
    }

    private InterviewFeedback toFeedback(InterviewGradedAnswerDto gradedAnswer) {
        InterviewScoreDto score = gradedAnswer.score();

        return InterviewFeedback.create(
                gradedAnswer.answerId(),
                score.accuracyScore(),
                score.structureScore(),
                score.clarityScore(),
                score.accuracyBaseRatio(),
                score.accuracyMultiplier(),
                score.irrelevantStatementCount(),
                score.improvementSuggestion()
        );
    }
}
