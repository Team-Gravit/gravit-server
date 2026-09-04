package gravit.code.interviewFeedback.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionSort;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewSessionTopic;
import gravit.code.interview.dto.internal.InterviewSessionAverageDto;
import gravit.code.interview.dto.response.InterviewRecentSessionResponse;
import gravit.code.interview.dto.response.InterviewScoreTrendResponse;
import gravit.code.interview.dto.response.InterviewSessionHistoryResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interview.repository.InterviewSessionTopicRepository;
import gravit.code.interviewFeedback.dto.internal.InterviewAnswerDetailDto;
import gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto;
import gravit.code.interviewFeedback.dto.internal.InterviewTopicAccuracyDto;
import gravit.code.interviewFeedback.dto.response.InterviewAnswerDetailResponse;
import gravit.code.interviewFeedback.dto.response.InterviewAnswerScoreResponse;
import gravit.code.interviewFeedback.dto.response.InterviewDashboardResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionAnswersResponse;
import gravit.code.interviewFeedback.dto.response.InterviewSessionSummaryResponse;
import gravit.code.interviewFeedback.dto.response.InterviewTopicAccuracyResponse;
import gravit.code.interviewFeedback.dto.response.InterviewWeakTopicResponse;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.response.InterviewConceptResponse;
import gravit.code.interviewQuestion.repository.InterviewQuestionConceptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InterviewFeedbackQueryService {

    private static final int PAGE_SIZE = 10;
    private static final int RECENT_SESSION_COUNT = 5;
    private static final int DASHBOARD_RECENT_SESSION_COUNT = 3;
    private static final int WEAKEST_TOPIC_COUNT = 3;

    private static final double EMPTY_AVERAGE = 0.0;

    private static final Pageable RECENT_SESSION_PAGE = PageRequest.of(0, RECENT_SESSION_COUNT);

    private final InterviewSessionRepository interviewSessionRepository;
    private final InterviewSessionTopicRepository interviewSessionTopicRepository;
    private final InterviewQuestionConceptRepository interviewQuestionConceptRepository;
    private final InterviewFeedbackRepository interviewFeedbackRepository;

    @Transactional(readOnly = true)
    public SliceResponse<InterviewSessionHistoryResponse> getSessionHistory(
            long userId,
            int page,
            InterviewSessionSort sort
    ) {
        Pageable pageable = PageRequest.of(Math.max(0, page), PAGE_SIZE, sort.toSort());

        Slice<InterviewSession> sessions = interviewSessionRepository.findAllByUserIdAndStatus(
                userId,
                InterviewSessionStatus.COMPLETED,
                pageable
        );

        List<InterviewSessionHistoryResponse> contents = toHistoryResponses(sessions.getContent());

        return SliceResponse.of(sessions.hasNext(), contents);
    }

    @Transactional(readOnly = true)
    public InterviewSessionSummaryResponse getSessionSummary(
            long userId,
            long sessionId
    ) {
        InterviewSession session = getCompletedSession(userId, sessionId);

        InterviewSessionAverageDto averageScores = interviewSessionRepository.findAverageScoresByStatus(InterviewSessionStatus.COMPLETED);
        int averageAccuracyScore = (int) Math.round(averageScores.accuracyScore());
        int averageDeliveryScore = (int) Math.round(averageScores.deliveryScore());

        List<InterviewRecentSessionResponse> recentSessions = interviewSessionRepository
                .findRecentByUserIdAndStatusStartedAtOrBefore(
                        userId,
                        InterviewSessionStatus.COMPLETED,
                        session.getStartedAt(),
                        RECENT_SESSION_PAGE
                )
                .reversed()
                .stream()
                .map(InterviewRecentSessionResponse::from)
                .toList();

        List<InterviewAnswerScoreDto> scores = interviewFeedbackRepository.findAnswerScoresBySessionId(sessionId);

        List<InterviewAnswerScoreResponse> answers = scores.stream()
                .map(InterviewAnswerScoreResponse::from)
                .toList();

        List<InterviewWeakTopicResponse> weakTopics = toWeakTopics(scores, session);

        return InterviewSessionSummaryResponse.of(
                session,
                averageAccuracyScore,
                averageDeliveryScore,
                recentSessions,
                answers,
                weakTopics
        );
    }

    @Transactional(readOnly = true)
    public InterviewSessionAnswersResponse getSessionAnswers(
            long userId,
            long sessionId
    ) {
        InterviewSession session = getCompletedSession(userId, sessionId);

        List<InterviewAnswerDetailDto> details = interviewFeedbackRepository.findAnswerDetailsBySessionId(sessionId);

        Map<Long, List<InterviewConceptResponse>> questionIdToConcepts = groupConceptsByQuestionId(details);

        List<InterviewAnswerDetailResponse> answers = details.stream()
                .map(detail -> InterviewAnswerDetailResponse.of(
                        detail,
                        questionIdToConcepts.getOrDefault(detail.questionId(), List.of()),
                        session
                ))
                .toList();

        return InterviewSessionAnswersResponse.of(sessionId, answers);
    }

    @Transactional(readOnly = true)
    public InterviewDashboardResponse getDashboard(long userId) {
        long completedSessionCount = interviewSessionRepository.countByUserIdAndStatus(
                userId,
                InterviewSessionStatus.COMPLETED
        );

        List<InterviewSession> recentCompletedSessions = interviewSessionRepository.findRecentByUserIdAndStatus(
                userId,
                InterviewSessionStatus.COMPLETED,
                RECENT_SESSION_PAGE
        );

        int recentAverageScore = (int) Math.round(recentCompletedSessions.stream()
                .mapToInt(InterviewSession::getScore)
                .average()
                .orElse(EMPTY_AVERAGE));

        List<InterviewSessionHistoryResponse> recentSessions = toHistoryResponses(recentCompletedSessions.stream()
                .limit(DASHBOARD_RECENT_SESSION_COUNT)
                .toList());

        List<InterviewScoreTrendResponse> scoreTrends = recentCompletedSessions.reversed().stream()
                .map(InterviewScoreTrendResponse::from)
                .toList();

        List<InterviewTopicAccuracyResponse> weakestTopics = calculateTopicAccuracies(userId).stream()
                .limit(WEAKEST_TOPIC_COUNT)
                .toList();

        return InterviewDashboardResponse.of(
                completedSessionCount,
                recentAverageScore,
                weakestTopics,
                recentSessions,
                scoreTrends
        );
    }

    @Transactional(readOnly = true)
    public List<InterviewTopicAccuracyResponse> getWeakTopics(long userId) {
        return calculateTopicAccuracies(userId);
    }

    private InterviewSession getCompletedSession(
            long userId,
            long sessionId
    ) {
        InterviewSession session = interviewSessionRepository.findById(sessionId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND));

        if (!session.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED);
        }

        if (!session.isCompleted()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_FEEDBACK_NOT_READY);
        }

        return session;
    }

    private List<InterviewSessionHistoryResponse> toHistoryResponses(List<InterviewSession> sessions) {
        if (sessions.isEmpty()) {
            return List.of();
        }

        List<Long> sessionIds = sessions.stream()
                .map(InterviewSession::getId)
                .toList();

        Map<Long, List<InterviewTopic>> sessionIdToTopics = interviewSessionTopicRepository.findAllBySessionIdIn(sessionIds)
                .stream()
                .collect(Collectors.groupingBy(
                        InterviewSessionTopic::getSessionId,
                        Collectors.mapping(InterviewSessionTopic::getTopic, Collectors.toList())
                ));

        return sessions.stream()
                .map(session -> InterviewSessionHistoryResponse.of(
                        session,
                        sessionIdToTopics.getOrDefault(session.getId(), List.of()).stream().sorted().toList()
                ))
                .toList();
    }

    private List<InterviewWeakTopicResponse> toWeakTopics(
            List<InterviewAnswerScoreDto> scores,
            InterviewSession session
    ) {
        Map<Long, InterviewTopic> unitIdToTopic = scores.stream()
                .filter(score -> session.isWeakAnswer(score.earnedScore()))
                .collect(Collectors.toMap(
                        InterviewAnswerScoreDto::unitId,
                        InterviewAnswerScoreDto::topic,
                        (first, second) -> first,
                        LinkedHashMap::new
                ));

        return unitIdToTopic.entrySet().stream()
                .map(entry -> InterviewWeakTopicResponse.of(entry.getKey(), entry.getValue()))
                .toList();
    }

    private Map<Long, List<InterviewConceptResponse>> groupConceptsByQuestionId(List<InterviewAnswerDetailDto> details) {
        if (details.isEmpty()) {
            return Map.of();
        }

        List<Long> questionIds = details.stream()
                .map(InterviewAnswerDetailDto::questionId)
                .toList();

        return interviewQuestionConceptRepository.findAllByQuestionIds(questionIds)
                .stream()
                .collect(Collectors.groupingBy(
                        InterviewQuestionConcept::getQuestionId,
                        LinkedHashMap::new,
                        Collectors.mapping(InterviewConceptResponse::from, Collectors.toList())
                ));
    }

    private List<InterviewTopicAccuracyResponse> calculateTopicAccuracies(long userId) {
        return interviewFeedbackRepository.findTopicAccuracyByUserIdAndStatus(userId, InterviewSessionStatus.COMPLETED)
                .stream()
                .sorted(Comparator.comparingDouble(InterviewTopicAccuracyDto::accuracyRate)
                        .thenComparing(InterviewTopicAccuracyDto::topic))
                .map(row -> InterviewTopicAccuracyResponse.of(row.topic(), row.accuracyRate()))
                .toList();
    }
}
