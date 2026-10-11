package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.internal.InterviewQuestionHistoryDto;
import gravit.code.interview.repository.InterviewAnswerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class InterviewAnswerQueryService {

    private final InterviewAnswerRepository interviewAnswerRepository;

    @Transactional(readOnly = true)
    public InterviewAnswer getById(long answerId) {
        return interviewAnswerRepository.findById(answerId)
                .orElseThrow(() -> new RestApiException(INTERVIEW_ANSWER_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public List<InterviewAnswer> getAllBySessionId(long sessionId) {
        return interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId);
    }

    @Transactional(readOnly = true)
    public Map<Long, InterviewQuestionHistoryDto> getQuestionIdToLatestHistory(
            long userId,
            Collection<Long> questionIds
    ) {
        if (questionIds.isEmpty()) {
            return Map.of();
        }

        return interviewAnswerRepository.findQuestionHistoriesByUserIdExcludingStatus(
                        userId, questionIds, InterviewSessionStatus.ABANDONED).stream()
                .collect(Collectors.toMap(
                        InterviewQuestionHistoryDto::questionId,
                        Function.identity(),
                        (latest, older) -> latest
                ));
    }
}
