package gravit.code.interviewFeedback.service;

import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingInputDto;
import gravit.code.interviewFeedback.infrastructure.InterviewGradingClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class InterviewGradingService {

    private final InterviewGradingClient interviewGradingClient;

    public InterviewGradingJudgmentDto judge(InterviewGradingInputDto input) {
        return interviewGradingClient.judge(input);
    }
}
