package gravit.code.interview.service;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.repository.InterviewAnswerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewAnswerQueryService {

    private final InterviewAnswerRepository interviewAnswerRepository;

    @Transactional(readOnly = true)
    public List<InterviewAnswer> getAllBySessionId(long sessionId) {
        return interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId);
    }
}
