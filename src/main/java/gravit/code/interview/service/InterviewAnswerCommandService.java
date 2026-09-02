package gravit.code.interview.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.dto.response.InterviewAnswerSubmitResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewAnswerCommandService {

    private final InterviewAnswerRepository interviewAnswerRepository;

    @Transactional
    public List<Long> createPendingAnswers(
            long sessionId,
            List<Long> questionIds
    ) {
        List<InterviewAnswer> answers = new ArrayList<>();

        for (int index = 0; index < questionIds.size(); index++) {
            answers.add(InterviewAnswer.createPending(
                    sessionId,
                    questionIds.get(index),
                    index + InterviewAnswer.FIRST_DISPLAY_ORDER
            ));
        }

        return interviewAnswerRepository.saveAll(answers).stream()
                .map(InterviewAnswer::getId)
                .toList();
    }

    @Transactional
    public InterviewAnswerSubmitResponse submit(
            long sessionId,
            int displayOrder,
            String content
    ) {
        InterviewAnswer answer = interviewAnswerRepository.findBySessionIdAndDisplayOrder(sessionId, displayOrder)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND));

        answer.submit(content, null);

        return InterviewAnswerSubmitResponse.create(answer.getId(), answer.getStatus());
    }
}
