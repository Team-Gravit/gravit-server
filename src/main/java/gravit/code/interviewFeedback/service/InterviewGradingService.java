package gravit.code.interviewFeedback.service;

import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgment;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingSource;
import gravit.code.interviewFeedback.infrastructure.InterviewGradingClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class InterviewGradingService {

    private final InterviewGradingClient interviewGradingClient;

    public InterviewGradingJudgment judge(InterviewGradingSource source) {
        return interviewGradingClient.judge(source);
    }
}
