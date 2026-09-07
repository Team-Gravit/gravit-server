package gravit.code.interview.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionTopic;
import gravit.code.interview.dto.event.InterviewSubmittedEvent;
import gravit.code.interview.dto.internal.InterviewSessionCreateDto;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.policy.InterviewAudioKeyPolicy;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interview.repository.InterviewSessionTopicRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InterviewSessionCommandService {

    private static final long ATTEMPT_COUNT_INCREMENT = 1L;
    private static final int FIRST_DISPLAY_ORDER = 1;

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewSessionTopicRepository interviewSessionTopicRepository;
    private final InterviewAnswerRepository interviewAnswerRepository;

    private final InterviewAudioKeyPolicy interviewAudioKeyPolicy;

    private final ApplicationEventPublisher publisher;
    private final Clock clock;

    @Transactional
    public long create(
            long userId,
            InterviewSessionCreateDto createDto
    ) {
        long attemptCount = interviewSessionRepository.findMaxAttemptCountByUserId(userId) + ATTEMPT_COUNT_INCREMENT;

        InterviewSession session = interviewSessionRepository.save(
                InterviewSession.create(
                        userId,
                        attemptCount,
                        createDto.mode(),
                        createDto.inputType(),
                        createDto.difficulty(),
                        createDto.stack()
                )
        );

        long sessionId = session.getId();

        interviewSessionTopicRepository.saveAll(
                createDto.topics().stream()
                        .map(topic -> InterviewSessionTopic.create(sessionId, topic))
                        .toList()
        );

        List<Long> orderedQuestionIds = createDto.orderedQuestionIds();
        List<InterviewAnswer> answers = new ArrayList<>();
        for (int index = 0; index < orderedQuestionIds.size(); index++) {
            answers.add(InterviewAnswer.create(sessionId, orderedQuestionIds.get(index), index + FIRST_DISPLAY_ORDER));
        }
        interviewAnswerRepository.saveAll(answers);

        return sessionId;
    }

    @Transactional
    public InterviewSessionStatusResponse abandon(
            long userId,
            long sessionId
    ) {
        InterviewSession session = findSession(sessionId);
        validateOwner(session, userId);

        session.abandon(LocalDateTime.now(clock));

        return InterviewSessionStatusResponse.of(session.getId(), session.getStatus());
    }

    @Transactional
    public InterviewSessionStatusResponse submit(
            long userId,
            long sessionId,
            List<InterviewAnswerSubmitRequest> answerRequests
    ) {
        InterviewSession session = findSession(sessionId);
        validateOwner(session, userId);
        validateInProgress(session);
        validateDisplayOrders(answerRequests);
        validateAudioKeys(session, answerRequests);

        List<InterviewAnswer> answers = interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId);
        validateAnswerCount(answers);

        LocalDateTime now = LocalDateTime.now(clock);
        submitAnswers(answers, answerRequests, now);
        session.startGrading(now);

        publisher.publishEvent(InterviewSubmittedEvent.of(sessionId));

        return InterviewSessionStatusResponse.of(session.getId(), session.getStatus());
    }

    @Transactional
    public void completeGrading(
            long sessionId,
            int accuracyScore,
            int deliveryScore
    ) {
        InterviewSession session = findSession(sessionId);

        session.completeGrading(accuracyScore, deliveryScore);
    }

    @Transactional
    public void failGrading(long sessionId) {
        InterviewSession session = findSession(sessionId);

        session.failGrading();
    }

    private InterviewSession findSession(long sessionId) {
        return interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND));
    }

    private void validateOwner(
            InterviewSession session,
            long userId
    ) {
        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED);
        }
    }

    private void validateInProgress(InterviewSession session) {
        if (!session.isInProgress()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }
    }

    private void validateDisplayOrders(List<InterviewAnswerSubmitRequest> answerRequests) {
        Set<Integer> displayOrders = answerRequests.stream()
                .map(InterviewAnswerSubmitRequest::displayOrder)
                .collect(Collectors.toSet());

        if (displayOrders.size() != InterviewSession.QUESTION_COUNT) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_ANSWER_ORDER_INVALID);
        }
    }

    private void validateAudioKeys(
            InterviewSession session,
            List<InterviewAnswerSubmitRequest> answerRequests
    ) {
        if (session.isTextInput()) {
            validateTextAudioKeysEmpty(answerRequests);
            return;
        }

        validateVoiceAudioKeys(session, answerRequests);
    }

    private void validateTextAudioKeysEmpty(List<InterviewAnswerSubmitRequest> answerRequests) {
        boolean hasAudioKey = answerRequests.stream()
                .anyMatch(answerRequest -> answerRequest.audioKey() != null);

        if (hasAudioKey) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH);
        }
    }

    private void validateVoiceAudioKeys(
            InterviewSession session,
            List<InterviewAnswerSubmitRequest> answerRequests
    ) {
        for (InterviewAnswerSubmitRequest answerRequest : answerRequests) {
            String audioKey = answerRequest.audioKey();
            if (audioKey == null || audioKey.isBlank()) {
                continue;
            }

            interviewAudioKeyPolicy.validate(session.getId(), answerRequest.displayOrder(), audioKey);
        }
    }

    private void validateAnswerCount(List<InterviewAnswer> answers) {
        if (answers.size() != InterviewSession.QUESTION_COUNT) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND);
        }
    }

    private void submitAnswers(
            List<InterviewAnswer> answers,
            List<InterviewAnswerSubmitRequest> answerRequests,
            LocalDateTime answeredAt
    ) {
        Map<Integer, InterviewAnswerSubmitRequest> displayOrderToRequest = answerRequests.stream()
                .collect(Collectors.toMap(InterviewAnswerSubmitRequest::displayOrder, Function.identity()));

        for (InterviewAnswer answer : answers) {
            InterviewAnswerSubmitRequest answerRequest = displayOrderToRequest.get(answer.getDisplayOrder());
            if (answerRequest == null) {
                throw new RestApiException(CustomErrorCode.INTERVIEW_ANSWER_ORDER_INVALID);
            }

            answer.submit(answerRequest.content(), answerRequest.audioKey(), answeredAt);
        }
    }
}
