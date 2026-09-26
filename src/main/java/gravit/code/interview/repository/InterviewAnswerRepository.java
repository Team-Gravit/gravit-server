package gravit.code.interview.repository;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.internal.InterviewQuestionHistoryDto;
import gravit.code.interview.dto.internal.InterviewSessionQuestionDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface InterviewAnswerRepository extends JpaRepository<InterviewAnswer, Long> {

    List<InterviewAnswer> findAllBySessionIdOrderByDisplayOrderAsc(long sessionId);

    @Query("""
            SELECT new gravit.code.interview.dto.internal.InterviewSessionQuestionDto(a.displayOrder, q.content)
            FROM InterviewAnswer a JOIN InterviewQuestion q ON q.id = a.questionId
            WHERE a.sessionId = :sessionId
            ORDER BY a.displayOrder ASC
    """)
    List<InterviewSessionQuestionDto> findQuestionsBySessionId(@Param("sessionId") long sessionId);

    @Query("""
            SELECT new gravit.code.interview.dto.internal.InterviewQuestionHistoryDto(
                a.questionId, s.startedAt, f.accuracyScore
            )
            FROM InterviewAnswer a
            JOIN InterviewSession s ON s.id = a.sessionId
            LEFT JOIN InterviewFeedback f ON f.answerId = a.id
            WHERE s.userId = :userId AND s.status <> :excludedStatus AND a.questionId IN :questionIds
            ORDER BY s.startedAt DESC, s.id DESC
    """)
    List<InterviewQuestionHistoryDto> findQuestionHistoriesByUserIdExcludingStatus(
            @Param("userId") long userId,
            @Param("questionIds") Collection<Long> questionIds,
            @Param("excludedStatus") InterviewSessionStatus excludedStatus
    );
}
