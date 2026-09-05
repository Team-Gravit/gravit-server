package gravit.code.interviewFeedback.repository;

import gravit.code.interviewFeedback.domain.InterviewFeedback;
import org.springframework.data.jpa.repository.JpaRepository;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interviewFeedback.dto.internal.InterviewAnswerDetailDto;
import gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto;
import gravit.code.interviewFeedback.dto.internal.InterviewTopicAccuracyDto;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InterviewFeedbackRepository extends JpaRepository<InterviewFeedback, Long> {

    @Query("""
            SELECT new gravit.code.interviewFeedback.dto.internal.InterviewAnswerScoreDto(
                a.displayOrder, q.topic, q.unitId, f.accuracyScore, f.structureScore, f.clarityScore
            )
            FROM InterviewFeedback f
            JOIN InterviewAnswer a ON a.id = f.answerId
            JOIN InterviewQuestion q ON q.id = a.questionId
            WHERE a.sessionId = :sessionId
            ORDER BY a.displayOrder ASC
    """)
    List<InterviewAnswerScoreDto> findAnswerScoresBySessionId(@Param("sessionId") long sessionId);

    @Query("""
            SELECT new gravit.code.interviewFeedback.dto.internal.InterviewAnswerDetailDto(
                a.displayOrder, q.id, q.topic, q.content, a.content, a.audioKey, q.modelAnswer,
                f.improvementSuggestion, f.accuracyScore, f.structureScore, f.clarityScore
            )
            FROM InterviewFeedback f
            JOIN InterviewAnswer a ON a.id = f.answerId
            JOIN InterviewQuestion q ON q.id = a.questionId
            WHERE a.sessionId = :sessionId
            ORDER BY a.displayOrder ASC
    """)
    List<InterviewAnswerDetailDto> findAnswerDetailsBySessionId(@Param("sessionId") long sessionId);

    @Query("""
            SELECT new gravit.code.interviewFeedback.dto.internal.InterviewTopicAccuracyDto(
                q.topic, SUM(f.accuracyScore), SUM(s.accuracyMaxScore)
            )
            FROM InterviewFeedback f
            JOIN InterviewAnswer a ON a.id = f.answerId
            JOIN InterviewSession s ON s.id = a.sessionId
            JOIN InterviewQuestion q ON q.id = a.questionId
            WHERE s.userId = :userId AND s.status = :status
            GROUP BY q.topic
    """)
    List<InterviewTopicAccuracyDto> findTopicAccuracyByUserIdAndStatus(
            @Param("userId") long userId,
            @Param("status") InterviewSessionStatus status
    );
}
